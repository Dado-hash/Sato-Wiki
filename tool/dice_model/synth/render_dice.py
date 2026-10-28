"""Render synthetic dice scenes with exact labels, for training the dice detector.

Run inside Blender (tested target: 4.2 LTS, Cycles on an NVIDIA GPU):
    blender -b -P render_dice.py -- --assets <dir> --out <dir> --count 3000 --seed 1

Each scene: a floor with a random CC0 texture (or a plain colour), lit by a random
HDRI and sometimes a lamp, 0 to 6 dice of a random style seen from above like a
phone would, and sometimes distractors (coins, dark buttons, blank cubes)
so the model learns that a dark dot on its own is not a die. The label of each
die is the face pointing up, known from the scene, and its box is the projection
of the die mesh, so no image needs labelling by hand.

Output, in COCO layout like prepare_dataset.py: <out>/images/*.jpg and
<out>/annotations.json (category ids 1 to 6 are the faces "1" to "6"). The json is
rewritten every 50 images, so a stopped run keeps what it rendered; --start lets
a second run continue the numbering.
"""

import argparse
import json
import math
import random
import sys
from pathlib import Path

import bpy
from bpy_extras.object_utils import world_to_camera_view
from mathutils import Euler, Matrix, Vector

# Face value -> outward normal on the die template. Opposite faces add up to 7.
FACE_NORMALS = {
    1: Vector((0, 0, 1)),
    6: Vector((0, 0, -1)),
    2: Vector((1, 0, 0)),
    5: Vector((-1, 0, 0)),
    3: Vector((0, 1, 0)),
    4: Vector((0, -1, 0)),
}
# Pip positions on a face, in units of the pip offset from the face centre.
PIP_LAYOUT = {
    1: [(0, 0)],
    2: [(-1, -1), (1, 1)],
    3: [(-1, -1), (0, 0), (1, 1)],
    4: [(-1, -1), (-1, 1), (1, -1), (1, 1)],
    5: [(-1, -1), (-1, 1), (0, 0), (1, -1), (1, 1)],
    6: [(-1, -1), (-1, 0), (-1, 1), (1, -1), (1, 0), (1, 1)],
}
BLACK, WHITE = (0.02, 0.02, 0.02), (0.85, 0.85, 0.85)
RED, BLUE = (0.60, 0.02, 0.02), (0.03, 0.10, 0.55)
# (weight, body RGB or None for random, pips): pips is one RGB for every face,
# "asian" for the common style with red 1 and 4 and blue or black others, or
# None for a colour that contrasts with a random body.
DIE_STYLES = [
    (28, (0.85, 0.85, 0.83), BLACK),  # white, black pips
    (10, (0.85, 0.85, 0.83), BLUE),  # white, blue pips
    (20, (0.85, 0.85, 0.83), "asian"),  # white, red 1 and 4
    (6, (0.80, 0.74, 0.60), "asian"),  # ivory, red 1 and 4
    (6, (0.80, 0.74, 0.60), BLACK),  # ivory
    (6, (0.02, 0.02, 0.02), WHITE),  # black, white pips
    (6, (0.55, 0.03, 0.03), WHITE),  # red, white pips
    (4, (0.85, 0.85, 0.83), RED),  # white, red pips
    (14, None, None),  # random colour, contrasting pips
]

TEXTURE_RES = (640, 480)


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--assets", type=Path, required=True, help="Folder from fetch_polyhaven.py")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--count", type=int, default=100)
    parser.add_argument("--start", type=int, default=0, help="First image number (to continue a run)")
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--samples", type=int, default=48)
    parser.add_argument("--cpu", action="store_true", help="Render on the CPU (for a quick test)")
    parser.add_argument("--debug", action="store_true", help="Print every object of each scene")
    return parser.parse_args(argv)


# --- scene setup -----------------------------------------------------------------------


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "JPEG"
    scene.view_settings.view_transform = "AgX"
    scene.world = bpy.data.worlds.new("World")
    scene.world.use_nodes = True
    return scene


def use_gpu(scene, samples, cpu):
    scene.cycles.samples = samples
    scene.cycles.use_denoising = True
    scene.cycles.max_bounces = 6
    if cpu:
        scene.cycles.device = "CPU"
        return
    prefs = bpy.context.preferences.addons["cycles"].preferences
    for backend in ("OPTIX", "CUDA"):
        try:
            prefs.compute_device_type = backend
        except TypeError:
            continue
        prefs.get_devices()
        gpus = [d for d in prefs.devices if d.type == backend]
        if gpus:
            for device in prefs.devices:
                device.use = device.type == backend
            scene.cycles.device = "GPU"
            print(f"Rendering on {backend}: {[d.name for d in gpus]}", flush=True)
            return
    print("No NVIDIA GPU found, rendering on the CPU", flush=True)
    scene.cycles.device = "CPU"


def principled(name, color, roughness, metallic=0.0, coat=0.0):
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    bsdf = material.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Coat Weight"].default_value = coat
    return material


def make_floor():
    mesh = bpy.data.meshes.new("Floor")
    size = 3.0
    mesh.from_pydata(
        [(-size, -size, 0), (size, -size, 0), (size, size, 0), (-size, size, 0)], [], [(0, 1, 2, 3)]
    )
    uv = mesh.uv_layers.new()
    for loop, co in zip(uv.data, [(0, 0), (1, 0), (1, 1), (0, 1)]):
        loop.uv = co
    floor = bpy.data.objects.new("Floor", mesh)
    bpy.context.scene.collection.objects.link(floor)
    return floor, size * 2


def set_floor_material(floor, floor_span, textures, assets, rng):
    material = bpy.data.materials.new("FloorMat")
    material.use_nodes = True
    nodes = material.node_tree.nodes
    links = material.node_tree.links
    bsdf = nodes["Principled BSDF"]
    roll = rng.random()
    if roll < 0.75 and textures:
        texture = rng.choice(textures)
        coords = nodes.new("ShaderNodeTexCoord")
        mapping = nodes.new("ShaderNodeMapping")
        # One texture tile covers 0.25 to 1.2 m of floor.
        tiles = floor_span / rng.uniform(0.25, 1.2)
        mapping.inputs["Scale"].default_value = (tiles, tiles, 1)
        mapping.inputs["Rotation"].default_value = (0, 0, rng.uniform(0, math.tau))
        links.new(coords.outputs["UV"], mapping.inputs["Vector"])

        def image_node(file_name, non_color):
            node = nodes.new("ShaderNodeTexImage")
            node.image = bpy.data.images.load(str(assets / "textures" / file_name), check_existing=True)
            if non_color:
                node.image.colorspace_settings.name = "Non-Color"
            links.new(mapping.outputs["Vector"], node.inputs["Vector"])
            return node

        diffuse = image_node(texture["diff"], False)
        tint = nodes.new("ShaderNodeHueSaturation")
        tint.inputs["Hue"].default_value = 0.5 + rng.uniform(-0.04, 0.04)
        tint.inputs["Value"].default_value = rng.uniform(0.7, 1.25)
        links.new(diffuse.outputs["Color"], tint.inputs["Color"])
        links.new(tint.outputs["Color"], bsdf.inputs["Base Color"])
        if "rough" in texture:
            links.new(image_node(texture["rough"], True).outputs["Color"], bsdf.inputs["Roughness"])
        if "nor" in texture:
            normal_map = nodes.new("ShaderNodeNormalMap")
            normal_map.inputs["Strength"].default_value = rng.uniform(0.3, 1.0)
            links.new(image_node(texture["nor"], True).outputs["Color"], normal_map.inputs["Color"])
            links.new(normal_map.outputs["Normal"], bsdf.inputs["Normal"])
    else:
        # Plain surface: paper, a cloth mat, a painted table.
        hue, sat, val = rng.random(), rng.uniform(0, 0.7), rng.uniform(0.05, 0.9)
        bsdf.inputs["Base Color"].default_value = (*hsv_to_rgb(hue, sat, val), 1)
        bsdf.inputs["Roughness"].default_value = rng.uniform(0.3, 0.95)
    floor.data.materials.clear()
    floor.data.materials.append(material)


def set_lighting(scene, hdris, assets, rng):
    nodes = scene.world.node_tree.nodes
    links = scene.world.node_tree.links
    nodes.clear()
    output = nodes.new("ShaderNodeOutputWorld")
    background = nodes.new("ShaderNodeBackground")
    background.inputs["Strength"].default_value = rng.uniform(0.35, 1.6)
    links.new(background.outputs["Background"], output.inputs["Surface"])
    if hdris:
        env = nodes.new("ShaderNodeTexEnvironment")
        env.image = bpy.data.images.load(str(assets / "hdris" / rng.choice(hdris)["file"]), check_existing=True)
        coords = nodes.new("ShaderNodeTexCoord")
        mapping = nodes.new("ShaderNodeMapping")
        mapping.inputs["Rotation"].default_value = (0, 0, rng.uniform(0, math.tau))
        links.new(coords.outputs["Generated"], mapping.inputs["Vector"])
        links.new(mapping.outputs["Vector"], env.inputs["Vector"])
        links.new(env.outputs["Color"], background.inputs["Color"])
    else:
        background.inputs["Color"].default_value = (0.8, 0.8, 0.8, 1)

    # Sometimes a desk lamp or the sun: hard shadows next to the dice.
    if rng.random() < 0.4:
        kind = rng.choice(["SUN", "AREA", "POINT"])
        light_data = bpy.data.lights.new("Lamp", kind)
        light = bpy.data.objects.new("Lamp", light_data)
        scene.collection.objects.link(light)
        warm = rng.uniform(0.75, 1.0)
        light_data.color = (1.0, warm, warm * rng.uniform(0.8, 1.0))
        if kind == "SUN":
            light_data.energy = rng.uniform(1.0, 4.0)
            light_data.angle = math.radians(rng.uniform(0.5, 8))
            light.rotation_euler = Euler((math.radians(rng.uniform(0, 60)), 0, rng.uniform(0, math.tau)))
        else:
            light_data.energy = rng.uniform(2, 15)
            if kind == "AREA":
                light_data.size = rng.uniform(0.05, 0.4)
            angle, dist = rng.uniform(0, math.tau), rng.uniform(0.1, 0.5)
            light.location = (dist * math.cos(angle), dist * math.sin(angle), rng.uniform(0.35, 0.8))
            light.rotation_euler = (Vector((0, 0, 0)) - light.location).to_track_quat("-Z", "Y").to_euler()


def hsv_to_rgb(h, s, v):
    import colorsys

    return colorsys.hsv_to_rgb(h, s, v)


# --- dice ------------------------------------------------------------------------------


def pick_style(rng):
    total = sum(weight for weight, _, _ in DIE_STYLES)
    roll = rng.uniform(0, total)
    for weight, body, pips in DIE_STYLES:
        roll -= weight
        if roll <= 0:
            break
    if body is None:
        body = hsv_to_rgb(rng.random(), rng.uniform(0.4, 1.0), rng.uniform(0.15, 0.85))
        brightness = 0.3 * body[0] + 0.6 * body[1] + 0.1 * body[2]
        pips = BLACK if brightness > 0.45 else WHITE
    # Size of the single pip of face 1, relative to the others.
    big_one = 1.0
    if pips == "asian":
        others = BLUE if rng.random() < 0.6 else BLACK
        pips = {value: RED if value in (1, 4) else others for value in range(1, 7)}
        big_one = rng.uniform(1.5, 2.0)
    elif not isinstance(pips, dict):
        pips = {value: pips for value in range(1, 7)}
    # Small variation so no two sets look the same.
    body = tuple(min(1.0, max(0.0, c * rng.uniform(0.9, 1.1))) for c in body)
    return body, pips, big_one


def make_die(size, rng):
    """A die with face 1 on +Z. Returns the body and its pip objects (children, one per colour)."""
    body_rgb, pip_colours, big_one = pick_style(rng)
    half = size / 2

    bpy.ops.mesh.primitive_cube_add(size=size)
    body = bpy.context.active_object
    body.name = "Die"
    bevel = body.modifiers.new("Bevel", "BEVEL")
    bevel.width = size * rng.uniform(0.08, 0.13)
    bevel.segments = 4
    body.data.materials.append(
        principled("DieBody", body_rgb, rng.uniform(0.15, 0.45), coat=rng.uniform(0, 0.6))
    )

    # Pips stay on the flat part of the face: offset + radius < 0.5 - bevel.
    pip_radius = size * rng.uniform(0.075, 0.09)
    offset = size * rng.uniform(0.23, 0.27)
    pips_by_colour: dict = {}
    for value, normal in FACE_NORMALS.items():
        # Two directions in the face plane.
        u = Vector((1, 0, 0)) if abs(normal.x) < 0.5 else Vector((0, 1, 0))
        v = normal.cross(u)
        for a, b in PIP_LAYOUT[value]:
            centre = normal * half + u * (a * offset) + v * (b * offset)
            radius = pip_radius * (big_one if value == 1 else 1.0)
            bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=radius, location=centre)
            pip = bpy.context.active_object
            # A flat dome on the face (local Z along the face normal): it reads as a
            # painted or inset pip.
            pip.rotation_euler = normal.to_track_quat("Z", "Y").to_euler()
            pip.scale = (1, 1, 0.22)
            pips_by_colour.setdefault(pip_colours[value], []).append(pip)
    pip_groups = []
    roughness = rng.uniform(0.2, 0.6)
    for colour, members in pips_by_colour.items():
        bpy.ops.object.select_all(action="DESELECT")
        for pip in members:
            pip.select_set(True)
        bpy.context.view_layer.objects.active = members[0]
        bpy.ops.object.join()
        group = bpy.context.active_object
        group.name = "Pips"
        group.data.materials.append(principled("DiePips", colour, roughness))
        group.parent = body
        pip_groups.append(group)
    return body, pip_groups


def orient_die(body, value, size, location_xy, rng):
    """Turns the die so `value` faces up, spins it, and sets it on the floor."""
    up = FACE_NORMALS[value].rotation_difference(Vector((0, 0, 1)))
    spin = Matrix.Rotation(rng.uniform(0, math.tau), 4, "Z").to_quaternion()
    tilt = Euler((math.radians(rng.gauss(0, 1.5)), math.radians(rng.gauss(0, 1.5)), 0)).to_quaternion()
    body.rotation_mode = "QUATERNION"
    body.rotation_quaternion = tilt @ spin @ up
    body.location = (location_xy[0], location_xy[1], size / 2)


def make_distractor(kind, location_xy, size, rng, scene):
    """Things that are not dice: coins, dark buttons, blank cubes."""
    x, y = location_xy
    if kind == "coin":
        bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=size * rng.uniform(0.5, 0.8), depth=size * 0.12, location=(x, y, size * 0.06))
        material = principled("Coin", rng.choice([(0.8, 0.6, 0.3), (0.7, 0.7, 0.7), (0.6, 0.35, 0.2)]), rng.uniform(0.2, 0.4), metallic=1.0)
    elif kind == "button":
        bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=size * rng.uniform(0.15, 0.4), depth=size * 0.1, location=(x, y, size * 0.05))
        material = principled("Button", (rng.uniform(0, 0.08),) * 3, rng.uniform(0.3, 0.7))
    else:  # blank cube
        bpy.ops.mesh.primitive_cube_add(size=size, location=(x, y, size / 2), rotation=(0, 0, rng.uniform(0, math.tau)))
        bpy.context.active_object.modifiers.new("Bevel", "BEVEL").width = size * 0.12
        material = principled("Blank", hsv_to_rgb(rng.random(), rng.uniform(0, 0.8), rng.uniform(0.2, 0.9)), rng.uniform(0.2, 0.6))
    obj = bpy.context.active_object
    obj.data.materials.append(material)
    obj["synthetic"] = True
    return obj


# --- camera and labels -----------------------------------------------------------------


def place_camera(scene, rng):
    camera = scene.camera
    lens = rng.uniform(22, 30)  # 35 mm equivalent of phone main cameras
    camera.data.lens = lens
    # Blender's default near clip (0.1 m) would cut the table and dice when the
    # phone is closer than 10 cm.
    camera.data.clip_start = 0.002
    camera.data.sensor_width = 36
    height = rng.uniform(0.07, 0.35)  # metres above the table
    tilt = math.radians(rng.uniform(0, 25))
    heading = rng.uniform(0, math.tau)
    target = Vector((rng.uniform(-0.02, 0.02), rng.uniform(-0.02, 0.02), 0))
    camera.location = target + Vector(
        (math.sin(tilt) * math.cos(heading) * height, math.sin(tilt) * math.sin(heading) * height, math.cos(tilt) * height)
    )
    look = (target - camera.location).to_track_quat("-Z", "Y")
    roll = Matrix.Rotation(rng.uniform(0, math.tau), 4, (target - camera.location).normalized()).to_quaternion()
    camera.rotation_mode = "QUATERNION"
    camera.rotation_quaternion = roll @ look
    scene.view_settings.exposure = rng.uniform(-0.6, 0.6)
    return height, lens


def safe_reach(height, lens, aspect):
    """Half side of a floor square that stays in frame for any camera roll.

    Half of the short side of the view at the floor, times 0.7 (a square inscribed
    in the circle the view's short side sweeps when the camera rolls).
    """
    half_long = height * 18 / lens
    return 0.7 * half_long / max(aspect, 1 / aspect)


def projected_box(scene, obj):
    """Pixel box (x, y, w, h) of an object's evaluated mesh, and the fraction inside the frame."""
    depsgraph = bpy.context.evaluated_depsgraph_get()
    evaluated = obj.evaluated_get(depsgraph)
    mesh = evaluated.to_mesh()
    width, height = scene.render.resolution_x, scene.render.resolution_y
    xs, ys = [], []
    for vertex in mesh.vertices:
        co = world_to_camera_view(scene, scene.camera, evaluated.matrix_world @ vertex.co)
        xs.append(co.x * width)
        ys.append((1 - co.y) * height)
    evaluated.to_mesh_clear()
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    full = max(1e-6, (x1 - x0) * (y1 - y0))
    cx0, cx1 = max(0.0, x0), min(float(width), x1)
    cy0, cy1 = max(0.0, y0), min(float(height), y1)
    clipped = max(0.0, cx1 - cx0) * max(0.0, cy1 - cy0)
    return (cx0, cy0, cx1 - cx0, cy1 - cy0), clipped / full


def clear_props(scene):
    for obj in list(scene.objects):
        if obj.type in {"MESH", "LIGHT"} and obj.name != "Floor":
            bpy.data.objects.remove(obj, do_unlink=True)
    bpy.data.orphans_purge(do_local_ids=True, do_linked_ids=True, do_recursive=True)


# --- main ------------------------------------------------------------------------------


def main():
    args = parse_args()
    rng = random.Random(args.seed * 1_000_003 + args.start)
    manifest = json.loads((args.assets / "manifest.json").read_text(encoding="utf-8"))
    textures, hdris = manifest["textures"], manifest["hdris"]

    scene = reset_scene()
    use_gpu(scene, args.samples, args.cpu)
    floor, floor_span = make_floor()
    camera_data = bpy.data.cameras.new("Camera")
    camera = bpy.data.objects.new("Camera", camera_data)
    scene.collection.objects.link(camera)
    scene.camera = camera

    images_dir = args.out / "images"
    images_dir.mkdir(parents=True, exist_ok=True)
    ann_path = args.out / "annotations.json"
    coco = (
        json.loads(ann_path.read_text(encoding="utf-8"))
        if ann_path.exists()
        else {
            "images": [],
            "annotations": [],
            "categories": [{"id": v, "name": str(v), "supercategory": "die"} for v in range(1, 7)],
        }
    )
    done = {image["file_name"] for image in coco["images"]}
    next_ann = max((a["id"] for a in coco["annotations"]), default=0) + 1
    next_img = max((i["id"] for i in coco["images"]), default=0) + 1

    for index in range(args.start, args.start + args.count):
        file_name = f"synth_s{args.seed}_{index:05d}.jpg"
        if file_name in done:
            continue
        clear_props(scene)
        width, height = TEXTURE_RES if rng.random() < 0.5 else TEXTURE_RES[::-1]
        scene.render.resolution_x, scene.render.resolution_y = width, height
        scene.render.image_settings.quality = rng.randint(70, 95)
        set_floor_material(floor, floor_span, textures, args.assets, rng)
        set_lighting(scene, hdris, args.assets, rng)
        cam_height, lens = place_camera(scene, rng)

        die_size = rng.uniform(0.012, 0.02)
        reach = safe_reach(cam_height, lens, width / height)
        count = 0 if rng.random() < 0.08 else rng.randint(1, 6)
        distractors = rng.randint(1, 4) if rng.random() < 0.35 else 0
        spots: list = []
        min_gap = die_size * 1.9
        for _ in range(200):
            if len(spots) >= count + distractors:
                break
            spot = (rng.uniform(-reach, reach), rng.uniform(-reach, reach))
            if all(math.dist(spot, other) > min_gap for other in spots):
                spots.append(spot)

        dice = []
        for spot in spots[:count]:
            value = rng.randint(1, 6)
            body, pips = make_die(die_size, rng)
            orient_die(body, value, die_size, spot, rng)
            dice.append((body, pips, value))
        for spot in spots[count:]:
            make_distractor(rng.choice(["coin", "button", "button", "blank"]), spot, die_size, rng, scene)

        bpy.context.view_layer.update()
        labels = []
        for body, pips, value in dice:
            box, inside = projected_box(scene, body)
            if inside < 0.6 or box[2] < 6 or box[3] < 6:
                # Mostly out of frame: hide it rather than label half a die.
                body.hide_render = True
                for group in pips:
                    group.hide_render = True
                continue
            labels.append((value, box))

        if args.debug:
            for obj in scene.objects:
                print(f"  {obj.name:10} {obj.type:6} loc {tuple(round(c, 3) for c in obj.matrix_world.translation)} "
                      f"dims {tuple(round(c, 3) for c in obj.dimensions)} hidden {obj.hide_render}", flush=True)
        scene.render.filepath = str(images_dir / file_name)
        bpy.ops.render.render(write_still=True)

        coco["images"].append({"id": next_img, "file_name": file_name, "width": width, "height": height})
        for value, (x, y, w, h) in labels:
            coco["annotations"].append(
                {"id": next_ann, "image_id": next_img, "category_id": value,
                 "bbox": [round(x, 2), round(y, 2), round(w, 2), round(h, 2)],
                 "area": round(w * h, 2), "iscrowd": 0}
            )
            next_ann += 1
        next_img += 1
        print(f"{file_name}: {len(labels)} dice, camera {cam_height:.2f} m", flush=True)
        if next_img % 50 == 0:
            ann_path.write_text(json.dumps(coco), encoding="utf-8")

    ann_path.write_text(json.dumps(coco), encoding="utf-8")
    print(f"done: {len(coco['images'])} images, {len(coco['annotations'])} dice in {ann_path}", flush=True)


main()
