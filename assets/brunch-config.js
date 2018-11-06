exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
        "js/main.js": /^(js\/main|vendor|node_modules)/,
        "js/mnist.js": /^(js\/mnist|node_modules)/,
        "js/nlp.js": /^(js\/nlp|node_modules)/,
        "js/twitter.js": /^(js\/twitter|node_modules)/
      },

      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //   "js/app.js": /^js/,
      //   "js/vendor.js": /^(?!js)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "vendor/js/jquery-2.1.1.js",
      //     "vendor/js/bootstrap.min.js"
      //   ]
      // }
      order: {
        before: [
          "vendor/js/d3/d3.layout.cloud.js"
        ]
      }
    },
    stylesheets: {
      joinTo: {
        "css/app.css": /^(css\/app|vendor|node_modules)/,
        "css/main.css": /^(css\/main)/,
        "css/mnist.css": /^(css\/mnist)/,
        "css/nlp.css": /^(css\/nlp)/,
        "css/twitter.css": /^(css\/twitter)/
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["static", "css", "js", "vendor", "scss", "fonts"],
    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    },
    sass: {
      mode: "native",
      options: {
        includePaths: [
          "node_modules/bootstrap/scss",
          "node_modules/tether/scss",
          "node_modules/font-awesome/scss"
        ],
        precision: 8
      }
    },
    copycat: {
      "fonts": ["static/fonts", "node_modules/font-awesome/fonts"],
      verbose: false,
      onlyChanged: true
    }
  },

  modules: {
    autoRequire: {
      "js/main.js": ["js/main"],
      "js/mnist.js": ["js/mnist"],
      "js/nlp.js": ["js/nlp"],
      "js/twitter.js": ["js/twitter"],
      "css/main.css": ["css/main"],
      "css/mnist.css": ["css/mnist"],
      "css/nlp.css": ["css/nlp"],
      "css/twitter.css": ["css/twitter"]
    }
  },

  npm: {
    enabled: true,
    whitelist: [
      "jquery",
      "popper",
      "bootstrap",
      "tether",
      "d3",
      "d3-force",
      "d3-geo-projection",
      "d3-random",
      "d3-transition",
      "topojson"
    ],
    globals: {
      $: "jquery",
      jQuery: "jquery",
      Popper: "popper.js",
      Tether: "tether",
      bootstrap: "bootstrap",
      d3: "d3",
      topojson: "topojson"
    }
  }
};
