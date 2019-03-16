export var SystemDiagram = {
  run: function() {
    let svg =
      d3.select("#system-diagram")
        .append("div")
        .classed("svg-container", true)
        .append("svg")
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 640 480")

    let
      margin = {top: 10, right: 10, bottom: 10, left: 10},
      pad = 15,
      shift = 0.65,
      width = svg.attr("viewBox").split(" ")[2],
      height = svg.attr("viewBox").split(" ")[3],
      defs = svg.append("defs"),
      group = svg.append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`)

    let
      tetra = {width: shift * width - 2 * margin.left, height: height / 2 - 2 * margin.top},
      mono = {width: (1.0 - shift) * width - pad, height: 0.25 * height},
      data = {width: tetra.width / 3 - pad , height: tetra.height - 3 * pad},
      container = {width: mono.width - 2 * pad, height: mono.height - 3 * pad},
      micro = {type: "t3.micro", color: "orange"},
      nano = {type: "t3.nano", color: "cornflowerblue"}

    let main = {
      defs: defs,
      group: group,
      origin: {x: 0, y: 0},
      name: "main.datapun.net",
      ec2: micro.type,
      color: micro.color,
      dimensions: tetra,
      services: [
        {
          name: "nginx",
          description: "Reverse proxy",
          color: "lightgreen",
          background: "snow",
          origin: {
            x: pad,
            y: 0.2 * tetra.height
          },
          dimensions: container
        },
        {
          name: "assets",
          description: "Static asset volume",
          color: "beige",
          background: "papayawhip",
          origin: {
            x: pad,
            y: 0.6 * tetra.height
          },
          dimensions: container
        },
        {
          name: "bayberry",
          description: "Main site",
          language: "Elixir / Phoenix",
          color: "orchid",
          background: "snow",
          origin: {
            x: 0.5 * tetra.width,
            y: 0.2 * tetra.height
          },
          dimensions: container
        }
      ]
    }
    instance(main)

    let storage = {
      defs: defs,
      group: group,
      origin: {x: 0, y: tetra.height + pad},
      name: "storage.datapun.net",
      ec2: micro.type,
      color: micro.color,
      dimensions: tetra,
      services: [
        {
          name: "postgres",
          description: "Relational database",
          color: "steelblue",
          background: "snow",
          origin: {
            x: pad,
            y: 0.2 * tetra.height
          },
          dimensions: container
        },
        {
          name: "data",
          description: "Database volume",
          color: "beige",
          background: "papayawhip",
          origin: {
            x: pad,
            y: 0.6 * tetra.height
          },
          dimensions: container
        },
        {
          name: "rabbitmq",
          description: "Message broker",
          color: "coral",
          background: "snow",
          origin: {
            x: 0.5 * tetra.width,
            y: 0.2 * tetra.height
          },
          dimensions: container
        },
        {
          name: "redis",
          description: "Key-value store",
          color: "indianred",
          background: "snow",
          origin: {
            x: 0.5 * tetra.width,
            y: 0.6 * tetra.height
          },
          dimensions: container
        }
      ]
    }
    instance(storage)

    let mnist = {
      defs: defs,
      group: group,
      origin: {x: tetra.width + pad, y: 0},
      name: "mnist.datapun.net",
      ec2: micro.type,
      color: micro.color,
      dimensions: mono,
      services: [
        {
          name: "blueberry",
          description: "Image classification",
          language: "Python / Flask",
          color: "skyblue",
          background: "snow",
          origin: {
            x: 0.5 * (mono.width - container.width),
            y: 0.8 * (mono.height - container.height)
          },
          dimensions: container
        }
      ]
    }
    instance(mnist)

    let nlp = {
      defs: defs,
      group: group,
      origin: {x: tetra.width + pad, y: height / 3},
      name: "nlp.datapun.net",
      ec2: nano.type,
      color: nano.color,
      dimensions: mono,
      services: [
        {
          name: "cloudberry",
          description: "Natural language processing",
          language: "Scala / Finch",
          color: "salmon",
          background: "snow",
          origin: {
            x: 0.5 * (mono.width - container.width),
            y: 0.8 * (mono.height - container.height)
          },
          dimensions: container
        }
      ]
    }
    instance(nlp)

    let timeseries = {
      defs: defs,
      group: group,
      origin: {x: tetra.width + pad, y: 2 * height / 3},
      name: "timeseries.datapun.net",
      ec2: nano.type,
      color: nano.color,
      dimensions: mono,
      services: [
        {
          name: "cranberry",
          description: "Time series forecast",
          language: "Haskell / Snap",
          background: "snow",
          color: "plum",
          origin: {
            x: 0.5 * (mono.width - container.width),
            y: 0.8 * (mono.height - container.height)
          },
          dimensions: container
        }
      ]
    }
    instance(timeseries)

    let reverseProxy = {
      protocol: "tcp",
      start: {
        id: "#bayberry",
        offset: {x: 0, y: 0.5},
      },
      end: {
        id: "#nginx",
        offset: {x: 1, y: 0.5}
      }
    }
    protocol(group, reverseProxy)

    let database = {
      protocol: "tcp",
      start: {
        id: "#postgres",
        offset: {x: 0.3, y: 1},
      },
      end: {
        id: "#data",
        offset: {x: 0.3, y: 0}
      }
    }
    protocol(group, database)

    let dataModel = {
      protocol: "tcp",
      start: {
        id: "#bayberry",
        offset: {x: 0, y: 1},
      },
      end: {
        id: "#postgres",
        offset: {x: 1, y: 0}
      }
    }
    protocol(group, dataModel)

    let staticAssets = {
      protocol: "tcp",
      start: {
        id: "#nginx",
        offset: {x: 0.3, y: 1},
      },
      end: {
        id: "#assets",
        offset: {x: 0.3, y: 0}
      }
    }
    protocol(group, staticAssets)

    let mnistApi = {
      protocol: "tcp",
      start: {
        id: "#bayberry",
        offset: {x: 1, y: 0.5},
      },
      end: {
        id: "#blueberry",
        offset: {x: 0, y: 0.5}
      }
    }
    protocol(group, mnistApi)

    let nlpApi = {
      protocol: "tcp",
      start: {
        id: "#bayberry",
        offset: {x: 1, y: 1},
      },
      end: {
        id: "#cloudberry",
        offset: {x: 0, y: 0}
      }
    }
    protocol(group, nlpApi)

    let tweetApi = {
      protocol: "tcp",
      start: {
        id: "#bayberry",
        offset: {x: 1, y: 1},
      },
      end: {
        id: "#cranberry",
        offset: {x: 0, y: 0}
      }
    }
    protocol(group, tweetApi)

    let tweetSubscribe = {
      protocol: "amqp",
      start: {
        id: "#rabbitmq",
        offset: {x: 0.7, y: 0},
      },
      end: {
        id: "#bayberry",
        offset: {x: 0.7, y: 1}
      }
    }
    protocol(group, tweetSubscribe)

    let tweetPublish = {
      protocol: "amqp",
      start: {
        id: "#cranberry",
        offset: {x: 0, y: 0},
      },
      end: {
        id: "#rabbitmq",
        offset: {x: 1, y: 1}
      }
    }
    protocol(group, tweetPublish)

    let tweetCount = {
      protocol: "tcp",
      start: {
        id: "#cranberry",
        offset: {x: 0, y: 0.5},
      },
      end: {
        id: "#redis",
        offset: {x: 1, y: 0.5}
      }
    }
    protocol(group, tweetCount)
  }
}

function instance(host) {
  let group =
    host.group.append("g")
      .attr("x", host.origin.x)
      .attr("y", host.origin.y)
      .attr("transform", `translate(${host.origin.x},${host.origin.y})`)

  let server =
    group.append("rect")
      .attr("width", host.dimensions.width)
      .attr("height", host.dimensions.height)

  let gradient =
    host.defs
      .append("linearGradient")
      .attr("id", host.name)
      .attr("x1", "0")
      .attr("x2", "1")
      .attr("y1", "0")
      .attr("y2", "1")

  gradient.append("stop")
    .attr("stop-color", host.color)
    .attr("offset", "0")

  gradient.append("stop")
    .attr("stop-color", "white")
    .attr("offset", "1")

  server.attr("fill", `url(#${gradient.attr("id")})`)
      .style("stroke", "darkslategrey")
      .style("stroke-width", "1px")

  group.append("text")
    .attr("x", 0.5 * host.dimensions.width)
    .attr("y", d3.min(host.services.map(s => s.origin.y)) - 20)
    .attr("font-size", "12px")
    .attr("font-weight", "bold")
    .attr("fill", "black")
    .style("text-anchor", "middle")
    .text(host.name)

  group.append("text")
    .attr("x", 0.5 * host.dimensions.width)
    .attr("y", d3.min(host.services.map(s => s.origin.y)) - 5)
    .attr("font-size", "12px")
    .attr("fill", "black")
    .style("text-anchor", "middle")
    .text(host.ec2)

  for (var service of host.services) {
    let container =
      group.append("rect")
        .attr("x", service.origin.x)
        .attr("y", service.origin.y)
        .attr("width", service.dimensions.width)
        .attr("height", service.dimensions.height)
        .style("fill", service.background)
        .style("stroke", "darkslategrey")
        .style("stroke-width", "1px")

    group.append("text")
      .attr("x", service.origin.x + 0.5 * service.dimensions.width)
      .attr("y", service.origin.y + 0.15 * service.dimensions.height)
      .attr("font-size", "10px")
      .attr("font-weight", "bold")
      .attr("fill", "black")
      .style("text-anchor", "middle")
      .text(service.name)

    let image =
      group.append("rect")
        .attr("id", service.name)
        .attr("x", 0.1 * service.dimensions.width + service.origin.x)
        .attr("y", 0.2 * service.dimensions.height + service.origin.y)
        .attr("width", 0.8 * service.dimensions.width)
        .attr("height", 0.7 * service.dimensions.height)
        .style("fill", service.color)
        .style("stroke", "darkslategrey")
        .style("stroke-width", "1px")

      group.append("text")
        .attr("x", service.origin.x + 0.5 * service.dimensions.width)
        .attr("y", service.origin.y + 0.5 * service.dimensions.height)
        .attr("font-size", "10px")
        .attr("font-weight", "bold")
        .attr("fill", "black")
        .style("text-anchor", "middle")
        .text(service.description)

      group.append("text")
        .attr("x", service.origin.x + 0.5 * service.dimensions.width)
        .attr("y", service.origin.y + 0.7 * service.dimensions.height)
        .attr("font-size", "10px")
        .attr("font-weight", "bold")
        .attr("fill", "black")
        .style("text-anchor", "middle")
        .text(service.language)
  }
}

function protocol(group, path) {
  let start = endpoint(path.start.id, path.start.offset)
  let end = endpoint(path.end.id, path.end.offset)

  let origin = d3.select(path.start.id)
  let destination = d3.select(path.end.id)

  let datum = [
    {x: start.x, y: start.y},
    {x: end.x, y: end.y}
  ]

  let line = d3.line()
    .x(d => d.x)
    .y(d => d.y)

  let connection =
    group.append("path")
      .datum(datum)
      .attr("d", line)
      .attr("fill", "none")
      .attr("stroke", "white")
      .attr("stroke-width", "8px")
      .style("opacity", 0.4)

  let
    ping = 10,
    length = connection.node().getTotalLength(),
    tcp = document.createElement("style"),
    name = `${path.start.id}-${path.end.id}`.replace(/#/g, '')

  let
    keyFrames =
      `@keyframes ${name} {
        0% { stroke-dashoffset: ${2 * ping}; }
        25% { stroke-dashoffset: ${2 * ping}; }
        100% { stroke-dashoffset: -LENGTH; }
      }`

  tcp.type = "text/css"
  tcp.innerHTML = keyFrames.replace(/LENGTH/g, length + ping)
  document.getElementsByTagName("head")[0].appendChild(tcp)

  let stroke = {
    amqp: {
      animation: "amqp linear 3s infinite",
      dashes: `${ping} ${length / 3}`
    },
    tcp: {
      animation: `${name} linear 1s ${2 * Math.random()}s infinite alternate`,
      dashes: `${ping} ${length + 4 * ping}`
    }
  }

  let packets =
    group.append("path")
      .datum(datum)
      .attr("d", line)
      .attr("fill", "none")
      .attr("stroke", "darkorange")
      .attr("stroke-width", "2px")
      .attr("stroke-dashoffset", ping)
      .attr("stroke-dasharray", stroke[path.protocol].dashes)
      .style("animation", stroke[path.protocol].animation)

  connection.on("mouseover", () => {
    origin.style("stroke-width", "3px")
    destination.style("stroke-width", "3px")
    packets.style("stroke", "steelblue")
  }).on("mouseout", () => {
    origin.style("stroke-width", "1px")
    destination.style("stroke-width", "1px")
    packets.style("stroke", "darkorange")
  })
}

function endpoint(id, offset) {
  let image = d3.select(id)
  let host = d3.select(image.node().parentElement)

  let origin = {
    x: parseFloat(image.attr("x")) + parseFloat(host.attr("x")),
    y: parseFloat(image.attr("y")) + parseFloat(host.attr("y"))
  }

  let dimensions = {
    width: parseFloat(image.attr("width")),
    height: parseFloat(image.attr("height"))
  }

  let terminus = {
    x: origin.x + offset.x * dimensions.width,
    y: origin.y + offset.y * dimensions.height
  }

  return terminus
}
