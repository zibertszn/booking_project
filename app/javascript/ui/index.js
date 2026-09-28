import { createApp } from "vue"
import { uiComponents } from "./components"

export * from "./components"

export function registerUiKit(app) {
  Object.entries(uiComponents).forEach(([name, component]) => {
    app.component(name, component)
  })

  return app
}

export function createUiApp(rootComponent, props = {}) {
  return registerUiKit(createApp(rootComponent, props))
}

export { uiComponents }
