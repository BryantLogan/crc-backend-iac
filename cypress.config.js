const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl: "https://zfg8w7nleb.execute-api.us-east-1.amazonaws.com/prod/counter"
  },
});