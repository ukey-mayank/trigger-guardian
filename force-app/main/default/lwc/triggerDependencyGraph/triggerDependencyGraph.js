import { LightningElement, wire, track } from 'lwc';
import getTriggerDependencies from '@salesforce/apex/TriggerDependencyController.getTriggerDependencies';

export default class TriggerDependencyGraph extends LightningElement {
    @track graphData = { nodes: [], links: [] };
    @track selectedNode = null;

    connectedCallback() {
        this.loadGraphData();
    }

    loadGraphData() {
        getTriggerDependencies()
            .then(data => {
                this.graphData = JSON.parse(data);
                this.initGraph();
            })
            .catch(error => {
                console.error('Error loading trigger dependencies:', error);
            });
    }

    initGraph() {
        const container = this.template.querySelector('#graph');
        const graph = ForceGraph2D()(container)
            .graphData(this.graphData)
            .nodeLabel(node => node.label)
            .onNodeClick(node => this.handleNodeClick(node))
            .width(container.offsetWidth)
            .height(500)
            .backgroundColor('#f9f9f9');
    }

    handleNodeClick(node) {
        this.selectedNode = node;
    }

    closeModal() {
        this.selectedNode = null;
    }
}