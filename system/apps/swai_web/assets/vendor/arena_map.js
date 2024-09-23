import * as d3 from 'd3';
import * as d3_hex from 'd3-hexbin';


const consideredNewNode = 10; // seconds

let g = null;


export const HivesChanged = {
  mounted() {
    this.handleEvent("hives_changed", ({ hives }) => {
      this.el.dataset.hives = JSON.stringify(hives);
    });
  },
  updated() {
    this.handleEvent("hives_changed", ({ hives }) => {
      this.el.dataset.hives = JSON.stringify(hives);
    });
  }
};

export const ParticlesChanged = {
  mounted() {
    this.handleEvent("particles_changed", ({ particles }) => {
      this.el.dataset.particles = JSON.stringify(particles);
    });
  },
  updated() {
    this.handleEvent("particles_changed", ({ particles }) => {
      this.el.dataset.particles = JSON.stringify(particles);
    });
  }
};


export const ArenaMapChanged = {
  mounted() {
    this.handleEvent("arena_map_changed", ({ arena_map }) => {
      this.el.dataset.arena_map = JSON.stringify(arena_map);
    });
  },
  updated() {
    this.handleEvent("arena_map_changed", ({ arena_map }) => {
      this.el.dataset.arena_map = JSON.stringify(arena_map);
    });
  }
};


export const TheArena = {
  mounted() {
    this.arena_map = JSON.parse(this.el.dataset.arena_map);
    console.log(this.arena_map);
    this.particles = JSON.parse(this.el.dataset.particles);
    this.hives = JSON.parse(this.el.dataset.hives);
    this.svg = drawArenaMap(this.el, 800, 600, 5);
  },
  updated() {
    this.arena_map = JSON.parse(this.el.dataset.arena_map);
    this.particles = JSON.parse(this.el.dataset.particles);
    this.hives = JSON.parse(this.el.dataset.hives);
    this.svg = drawArenaMap(this.el, 800, 600, 5);
  }
};



function drawArenaMap(an_el, width, height, hexa_size) {
  // if (this.svg != null) {
  //   return this.svg;
  // }
  d3.select(an_el)
    .selectAll("svg")
    .remove();
  const svg = d3.select(an_el)
    .append("svg")
    .attr("width", width)
    .attr("height", height);

  const margin = { top: 20, right: 25, bottom: 20, left: 20 };
  const innerWidth = width - margin.left - margin.right;
  const innerHeight = height - margin.top - margin.bottom;

  const g = svg.append("g")
    .attr("transform", `translate(${margin.left},${margin.top})`);

  const hexbin = d3_hex.hexbin()
    .radius(hexa_size)
    .extent([[0, 0], [width, height]]);

  const hexagons = hexbin(
    d3.range(width * height / (hexa_size * hexa_size))
      .map((d, i) => [i % width, Math.floor(i / width)])
  );

  g.append("g")
    .selectAll("path")
    .data(hexagons)
    .enter().append("path")
    .attr("d", hexbin.hexagon())
    .attr("transform", d => `translate(${d.x},${d.y})`)
    .attr("fill", "transparent")
    .attr("stroke", "lightgray");

  return svg;
}




