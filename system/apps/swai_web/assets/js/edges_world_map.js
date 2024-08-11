
import * as d3 from 'd3';
// import * as world_atlas from 'world-atlas';
import * as topojson from 'topojson-client';

// https://youtu.be/Qw6uAg3EO64
const maps_url = 'https://unpkg.com/world-atlas@1/world/110m.json';
const topojson_url = 'https://unpkg.com/topojson@3.0.2/dist/topojson.min.js';
const world_atlas_tsv = 'https://unpkg.com/world-atlas@1.1.4/world/110m.tsv';

export const EdgesChanged = {

  mounted() {
    this.handleEvent("edges_changed", ({ edges }) => {
      this.el.dataset.edges = JSON.stringify(edges);
      console.log(this.el.dataset.edges);
    });
  }
};

export const TheMap = {
  mounted() {
    const projection = d3.geoNaturalEarth1();
    const pathGenerator = d3.geoPath().projection(projection);
    const svg = d3.select(this.el);

    const g = svg.append("g");

    svg
      .call(d3
        .zoom()
        .on("zoom", () => {
          g.attr("transform", d3.event.transform);
        }));

    Promise
      .all([d3.tsv(world_atlas_tsv), d3.json(maps_url)])
      .then(
        ([atlas_data, tj_data]) => {

          const countryName = {};

          atlas_data.reduce((acc, d) => {
            acc[d.iso_n3] = d.name;
            return acc;
          }, countryName);


          const countries = topojson.feature(tj_data, tj_data.objects.countries);

          svg
            .attr("viewBox", "0 0 1000 500")
            .selectAll("path")
            .attr("fill", "transparent")
            .data(countries.features)
            .enter()
            .append("path")
            .attr("class", "map_country")
            .attr("d", pathGenerator)
            .attr("fill", "#a4aa4")
            .attr("stroke", "#5ae")
            .append("title")
            .text(d => countryName[d.id]);
        }
      );

  
  },
  updated() {
    console.log("Map updated");
  }
};