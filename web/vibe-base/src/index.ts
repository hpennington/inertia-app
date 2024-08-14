export class VibeDataModel {
    private containerId: string

    constructor(containerId: string) {
        this.containerId = containerId
    }

    public getId(): string {
        return this.containerId;
    }
}
