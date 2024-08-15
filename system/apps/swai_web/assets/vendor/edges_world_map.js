import * as d3 from 'd3';
import * as topojson from 'topojson-client';

const maps_url = 'https://unpkg.com/world-atlas@1/world/110m.json';
const topojson_url = 'https://unpkg.com/topojson@3.0.2/dist/topojson.min.js';
const world_atlas_tsv = 'https://unpkg.com/world-atlas@1.1.4/world/110m.tsv';

let g = null;


export const EdgesChanged = {
  mounted() {
    this.handleEvent("edges_changed", ({ edges }) => {
      this.el.dataset.edges = JSON.stringify(edges);
    });
  },
  updated() {
    this.handleEvent("edges_changed", ({ edges }) => {
      this.el.dataset.edges = JSON.stringify(edges);
    });
  }
};



export const TheMap = {
  mounted() {
    this.nodes = JSON.parse(this.el.dataset.edges);
    [this.svg, this.projection] = drawWorldMap(this.el, 1200, 600);
    createPoints(this.svg, this.nodes, this.projection);
    createCurvedLines(this.svg, this.nodes, this.projection);
  },
  updated() {
    this.nodes = JSON.parse(this.el.dataset.edges);
    [this.svg, this.projection] = drawWorldMap(this.el, 1200, 600);
    updatePoints(this.svg, this.nodes, this.projection);
    updateCurvedLines(this.svg, this.nodes, this.projection);
  }
};

function createPoints(a_svg, data, projection) {
  const tooltip = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("position", "absolute")
    .style("visibility", "hidden")
    .style("background", "#f9f9f9")
    .style("border", "1px solid #d3d3d3")
    .style("padding", "5px")
    .style("border-radius", "5px");

  const points = a_svg.selectAll("g.node")
    .data(data, d => d.id);

  const enter = points.enter().append("g")
    .attr("class", "node");

  enter.append("circle")
    .attr("cx", d => projection([d.lon, d.lat])[0])
    .attr("cy", d => projection([d.lon, d.lat])[1])
    .attr("r", 10)
    .attr("fill", node_color)
    .on("mouseover", function (event, d) {
      tooltip.style("visibility", "visible")
        .text(`Node: ${d.id}`);
    })
    .on("mousemove", function (event) {
      tooltip.style("top", (event.pageY - 10) + "px")
        .style("left", (event.pageX + 10) + "px");
    })
    .on("mouseout", function () {
      tooltip.style("visibility", "hidden");
    });

  enter.append("circle")
    .attr("cx", d => projection([d.lon, d.lat])[0])
    .attr("cy", d => projection([d.lon, d.lat])[1])
    .attr("r", 8)
    .attr("fill", "grey");

  enter.append("image")
    .attr("xlink:href", d => d.is_container ? "/images/docker-mark.svg" : "/images/erlang-mark.svg")
    .attr("width", 10)
    .attr("height", 10)
    .attr("x", d => projection([d.lon, d.lat])[0] - 5)
    .attr("y", d => projection([d.lon, d.lat])[1] - 5);

  points.exit().remove();
}

function updatePoints(a_svg, data, projection) {
  const tooltip = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("position", "absolute")
    .style("visibility", "hidden")
    .style("background", "#f9f9f9")
    .style("border", "1px solid #d3d3d3")
    .style("padding", "5px")
    .style("border-radius", "5px");

  const points = a_svg.selectAll("g.node")
    .data(data, d => d.id);

  const enter = points.enter().append("g")
    .attr("class", "node");

  enter.append("circle")
    .attr("cx", d => projection([d.lon, d.lat])[0])
    .attr("cy", d => projection([d.lon, d.lat])[1])
    .attr("r", 9)
    .attr("fill", node_color)
    .on("mouseover", function (event, d) {
      tooltip.style("visibility", "visible")
        .text(`Node: ${d.id}`);
    })
    .on("mousemove", function (event) {
      tooltip.style("top", (event.pageY - 10) + "px")
        .style("left", (event.pageX + 10) + "px");
    })
    .on("mouseout", function () {
      tooltip.style("visibility", "hidden");
    });

  enter.append("circle")
    .attr("cx", d => projection([d.lon, d.lat])[0])
    .attr("cy", d => projection([d.lon, d.lat])[1])
    .attr("r", 8)
    .attr("fill", "grey");

  enter.append("image")
    .attr("xlink:href", d => d.is_container ? "/images/docker-mark.svg" : "/images/erlang-mark.svg")
    .attr("width", 10)
    .attr("height", 10)
    .attr("x", d => projection([d.lon, d.lat])[0] - 5)
    .attr("y", d => projection([d.lon, d.lat])[1] - 5);

  points.select("circle")
    .attr("cx", d => projection([d.lon, d.lat])[0])
    .attr("cy", d => projection([d.lon, d.lat])[1])
    .attr("r", 10)
    .attr("fill", node_color);

  points.select("image")
    .attr("xlink:href", d => d.is_container ? "/images/docker-mark.svg" : "/images/erlang-mark.svg")
    .attr("x", d => projection([d.lon, d.lat])[0] - 5)
    .attr("y", d => projection([d.lon, d.lat])[1] - 5);

  points.exit().remove();
}

function createCurvedLines(a_svg, data, projection) {
  const links = data.filter(d => d.connected_to).map(d => ({
    source: d,
    target: data.find(node => node.id === d.connected_to)
  }));

  const lineGenerator = d3.linkHorizontal()
    .x(d => projection([d.lon, d.lat])[0])
    .y(d => projection([d.lon, d.lat])[1]);

  a_svg.selectAll(".node-lines")
    .data(links)
    .enter()
    .append("path")
    .attr("class", "node-lines")
    .attr("d", d => lineGenerator({ source: d.source, target: d.target }))
    .attr("fill", "blue")
    .attr("stroke", "grey") // Customize stroke color
    .attr("stroke-width", 2) // Customize stroke width
    .attr("stroke-dasharray", "5,5"); // Customize stroke dash pattern
}

function updateCurvedLines(a_svg, data, projection) {
  const links = data.filter(d => d.connected_to).map(d => ({
    source: d,
    target: data.find(node => node.id === d.connected_to)
  }));

  const lineGenerator = d3.linkHorizontal()
    .x(d => projection([d.lon, d.lat])[0])
    .y(d => projection([d.lon, d.lat])[1]);

  a_svg.selectAll(".node-lines")
    .data(links)
    .attr("d", d => lineGenerator({ source: d.source, target: d.target }))
    .attr("fill", "blue")
    .attr("stroke", "grey") // Customize stroke color
    .attr("stroke-width", 2) // Customize stroke width
    .attr("stroke-dasharray", "5,5"); // Customize stroke dash pattern
}

let node_color = function (d) {
  console.log(d.stats);
  if (d.stats.nbr_of_agents > 0) {
    return "green";
  } else {
    return "red";
  }
}

function drawWorldMap(an_el, width, height) {
  if (this.svg != null && this.projection != null) {
    return [this.svg, this.projection];
  }
  const svg = d3.select(an_el)
    .append("svg")
    .attr("width", width)
    .attr("height", height);
  const projection = d3.geoMercator()
    .scale(150)
    .translate([width / 2.5, height / 2]);
  const pathGenerator = d3.geoPath().projection(projection);

  Promise
    .all([
      d3.tsv(world_atlas_tsv),
      d3.json(maps_url)
    ])
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

  return [svg, projection];
}



// export const TheMap = {
//   mounted() {
//     this.nodes = JSON.parse(this.el.dataset.edges);
//     [this.svg, this.projection] = drawWorldMap(this.el, 1200, 600);
//     createPoints(this.svg, this.nodes, this.projection);
//     createCurvedLines(this.svg, this.nodes, this.projection);
//   },
//   updated() {
//     this.nodes = JSON.parse(this.el.dataset.edges);
//     [this.svg, this.projection] = drawWorldMap(this.el, 1200, 600);
//     updatePoints(this.svg, this.nodes, this.projection);
//     updateCurvedLines(this.svg, this.nodes, this.projection);
//   }
// };

// function createPoints(a_svg, data, projection) {
//   a_svg.selectAll("circle")
//     .data(data)
//     .enter()
//     .each(function (d) {
//       const group = d3.select(this).append("g");

//       group.append("circle")
//         .attr("cx", d => projection([d.lon, d.lat])[0])
//         .attr("cy", d => projection([d.lon, d.lat])[1])
//         .attr("r", 7)
//         .attr("fill", node_color(d));

//       if (d.is_container) {
//         group.append("image")
//           .attr("xlink:href", "/images/docker-mark.svg")
//           .attr("width", 10)
//           .attr("height", 10)
//           .attr("x", d => projection([d.lon, d.lat])[0] - 5)
//           .attr("y", d => projection([d.lon, d.lat])[1] - 5);
//       } else {
//         group.append("image")
//           .attr("xlink:href", "/images/erlang-mark.svg")
//           .attr("width", 10)
//           .attr("height", 10)
//           .attr("x", d => projection([d.lon, d.lat])[0] - 5)
//           .attr("y", d => projection([d.lon, d.lat])[1] - 5);
//       }
//     });
// }

// function updatePoints(a_svg, data, projection) {
//   const points = a_svg.selectAll("g").data(data);

//   points.enter()
//     .each(function (d) {
//       const group = d3.select(this).append("g");

//       group.append("circle")
//         .attr("cx", d => projection([d.lon, d.lat])[0])
//         .attr("cy", d => projection([d.lon, d.lat])[1])
//         .attr("r", 7)
//         .attr("fill", node_color(d));

//       if (d.is_container) {
//         group.append("image")
//           .attr("xlink:href", "/images/docker-mark.svg")
//           .attr("width", 10)
//           .attr("height", 10)
//           .attr("x", d => projection([d.lon, d.lat])[0] - 5)
//           .attr("y", d => projection([d.lon, d.lat])[1] - 5);
//       } else {
//         group.append("image")
//           .attr("xlink:href", "/images/erlang-mark.svg")
//           .attr("width", 10)
//           .attr("height", 10)
//           .attr("x", d => projection([d.lon, d.lat])[0] - 5)
//           .attr("y", d => projection([d.lon, d.lat])[1] - 5);
//       }
//     });

//   points.select("circle")
//     .attr("cx", d => projection([d.lon, d.lat])[0])
//     .attr("cy", d => projection([d.lon, d.lat])[1])
//     .attr("fill", node_color(d));

//   points.select("image")
//     .attr("x", d => projection([d.lon, d.lat])[0] - 5)
//     .attr("y", d => projection([d.lon, d.lat])[1] - 5);

//   points.exit().remove();
// }

// function createCurvedLines(a_svg, data, projection) {
//   const links = data.filter(d => d.connected_to).map(d => ({
//     source: d,
//     target: data.find(node => node.id === d.connected_to)
//   }));

//   const lineGenerator = d3.linkHorizontal()
//     .x(d => projection([d.lon, d.lat])[0])
//     .y(d => projection([d.lon, d.lat])[1]);

//   a_svg.selectAll(".node-lines")
//     .data(links)
//     .enter()
//     .append("path")
//     .attr("class", "node-lines")
//     .attr("d", d => lineGenerator({ source: d.source, target: d.target }))
//     .attr("fill", "none")
//     .attr("stroke", "blue") // Customize stroke color
//     .attr("stroke-width", 2) // Customize stroke width
//     .attr("stroke-dasharray", "5,5"); // Customize stroke dash pattern
// }

// function updateCurvedLines(a_svg, data, projection) {
//   const links = data.filter(d => d.connected_to).map(d => ({
//     source: d,
//     target: data.find(node => node.id === d.connected_to)
//   }));

//   const lineGenerator = d3.linkHorizontal()
//     .x(d => projection([d.lon, d.lat])[0])
//     .y(d => projection([d.lon, d.lat])[1]);

//   a_svg.selectAll(".node-lines")
//     .data(links)
//     .attr("d", d => lineGenerator({ source: d.source, target: d.target }))
//     .attr("stroke", "blue") // Customize stroke color
//     .attr("stroke-width", 2) // Customize stroke width
//     .attr("stroke-dasharray", "5,5"); // Customize stroke dash pattern
// }

// let node_color = function (d) {
//   console.log(d.stats);
//   if (d.stats.nbr_of_agents > 0) {
//     return "white";
//   } else {
//     return "red";
//   }
// }

// function drawWorldMap(an_el, width, height) {
//   if (this.svg != null && this.projection != null) {

//     return [this.svg, this.projection];
//   }    
//   const svg = d3.select(an_el)
//     .append("svg")
//     .attr("width", width)
//     .attr("height", height);
//   const projection = d3.geoMercator()
//     .scale(150)
//     .translate([width / 2.5, height / 2]);
//   const pathGenerator = d3.geoPath().projection(projection);

//   Promise
//     .all([
//       d3.tsv(world_atlas_tsv),
//       d3.json(maps_url)
//     ])
//     .then(
//       ([atlas_data, tj_data]) => {
//         const countryName = {};

//         atlas_data.reduce((acc, d) => {
//           acc[d.iso_n3] = d.name;
//           return acc;
//         }, countryName);
//         const countries = topojson.feature(tj_data, tj_data.objects.countries);

//         svg
//           .attr("viewBox", "0 0 1000 500")
//           .selectAll("path")
//           .attr("fill", "transparent")
//           .data(countries.features)
//           .enter()
//           .append("path")
//           .attr("class", "map_country")
//           .attr("d", pathGenerator)
//           .attr("fill", "#a4aa4")
//           .attr("stroke", "#5ae")
//           .append("title")
//           .text(d => countryName[d.id]);

//       }
//     );
//   return [svg, projection];
// }



