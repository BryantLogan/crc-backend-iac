const { defineConfig } = require("cypress");

module.exports = defineConfig({
  projectId: "qxo2p9",
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl: "https://zfg8w7nleb.execute-api.us-east-1.amazonaws.com/prod/counter"
  },
});