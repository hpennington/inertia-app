type VibeSchema = {
    objects: Array<VibeObjectSchema>|null
}

type VibeObjectSchema = {

}

var vibeDataModel: VibeSchema

export class VibeDataModel {
    public async load(path: string): Promise<VibeSchema|null> {
        const res = await fetch(path)
        if (res.body) {
            return await res.json()
        }

        return null
    }

    public async init() {
        if (vibeDataModel != undefined && vibeDataModel != null) {
            this.schema = vibeDataModel
            this.objects = vibeDataModel.objects
        } else {
            const schema = await this.load(this.baseURL + "/" + this.containerId + ".json")
            if (schema) {
                this.schema = schema
                this.objects = schema.objects    
            }
        }

        console.log(this.schema)
    }

    private containerId: string
    private baseURL: string
    private schema: VibeSchema|null
    private objects: Array<VibeObjectSchema>|null

    constructor(containerId: string, baseURL: string) {
        this.containerId = containerId
        this.baseURL = baseURL
        this.schema = null
        this.objects = null

        console.log(this.schema)
    }

    
    public getId(): string {
        return this.containerId
    }

    public getSchema(): VibeSchema|null {
        return this.schema
    }

    public getObjects(): Array<VibeObjectSchema>|null {
        return this.objects
    }
}
