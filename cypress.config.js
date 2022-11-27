const { defineConfig } = require("cypress");

module.exports = defineConfig({
  projectId: "qxo2p9",
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl: "https://d9el2r2le6.execute-api.us-east-1.amazonaws.com/prod/counter"
  },
});