namespace Sen.Script.Helper.PvZ2.Animation.GenerateAtlasFromRecord {
    export const z_path: Array<string> = ["images", "1536", "full", "worldmap", "lostcity"];

    export const allowance = ["1536", "768", "384", "640", "1200"] as const;

    export function process(atlas: Support.PopCap.Atlas.Structure.Definition, record: Support.PopCap.Animation.RecordInfo): void {
        const ids: Array<string> = Object.keys(record.group);
        ids.forEach((id: string) => {
            atlas.groups[id] = {
                default: {
                    x: 0n,
                    y: 0n,
                },
                path: [...z_path, record.group[id].name].join("/"),
            };
        });
        return;
    }

    export function get_resolution(): Array<string> {
        return allowance.filter((e: string) => z_path.find((z: string) => z === e));
    }

    export function process_fs(): void {
        // TODO : add localization
        const record = Console.path("input path of record.json", "file");
        Console.send("input subgroup name", Definition.Console.Color.CYAN);
        const subgroup = Kernel.Console.readline();
        const resolutions = get_resolution();
        if (resolutions.length === 0) {
            throw new Error(`resolution not found, should match: ${allowance}`);
        }
        const destination = Kernel.Path.dirname(subgroup);
        resolutions.forEach((resolution) => {
            const atlas: Support.PopCap.Atlas.Structure.Definition = {
                expand_path: "array",
                method: "id",
                trim: false,
                subgroup: `${subgroup}_${resolution}`,
                res: resolution,
                groups: {},
            };
            process(atlas, Kernel.JSON.deserialize_fs<Support.PopCap.Animation.RecordInfo>(record));
            Kernel.JSON.serialize_fs(`${destination}/${subgroup}_${resolution}.json`, atlas, 1, false);
        });
        return;
    }
}
Sen.Script.Helper.PvZ2.Animation.GenerateAtlasFromRecord.process_fs();
