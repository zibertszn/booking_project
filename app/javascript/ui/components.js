import { h } from "vue"

const variantClass = (block, variant = "primary") => `${block}--${variant}`

export const UiButton = {
  name: "UiButton",
  props: {
    as: { type: String, default: "button" },
    variant: { type: String, default: "primary" },
    type: { type: String, default: "button" },
    disabled: { type: Boolean, default: false }
  },
  setup(props, { attrs, slots }) {
    return () => h(
      props.as,
      {
        ...attrs,
        type: props.as === "button" ? props.type : undefined,
        disabled: props.as === "button" ? props.disabled : undefined,
        class: ["ui-button", variantClass("ui-button", props.variant), attrs.class, props.disabled && "ui-button--disabled"]
      },
      slots.default?.()
    )
  }
}

export const UiBadge = {
  name: "UiBadge",
  props: {
    variant: { type: String, default: "primary" }
  },
  setup(props, { attrs, slots }) {
    return () => h(
      "span",
      { ...attrs, class: ["ui-badge", variantClass("ui-badge", props.variant), attrs.class] },
      slots.default?.()
    )
  }
}

export const UiCard = {
  name: "UiCard",
  setup(_, { attrs, slots }) {
    return () => h("article", { ...attrs, class: ["ui-card", attrs.class] }, [
      slots.header && h("header", { class: "ui-card__header" }, slots.header()),
      h("div", { class: "ui-card__body" }, slots.default?.()),
      slots.footer && h("footer", { class: "ui-card__footer" }, slots.footer())
    ])
  }
}

export const UiAlert = {
  name: "UiAlert",
  props: {
    variant: { type: String, default: "primary" },
    role: { type: String, default: "status" }
  },
  setup(props, { attrs, slots }) {
    return () => h(
      "div",
      { ...attrs, role: props.role, class: ["ui-alert", variantClass("ui-alert", props.variant), attrs.class] },
      slots.default?.()
    )
  }
}

export const UiFormField = {
  name: "UiFormField",
  props: {
    id: { type: String, required: true },
    label: { type: String, required: true },
    help: { type: String, default: "" }
  },
  setup(props, { slots }) {
    return () => h("div", { class: "ui-form-field" }, [
      h("label", { class: "ui-label", for: props.id }, props.label),
      slots.default?.({ id: props.id }),
      props.help && h("span", { class: "ui-help-text" }, props.help)
    ])
  }
}

export const UiResourceCard = {
  name: "UiResourceCard",
  props: {
    title: { type: String, required: true },
    description: { type: String, default: "" },
    meta: { type: Array, default: () => [] },
    status: { type: String, default: "Доступно" },
    statusVariant: { type: String, default: "success" }
  },
  setup(props, { slots }) {
    return () => h("article", { class: "ui-card ui-resource-card" }, [
      h("div", { class: "ui-cluster", style: "justify-content: space-between;" }, [
        h("h3", { class: "ui-title", style: "font-size: 1.25rem;" }, props.title),
        h(UiBadge, { variant: props.statusVariant }, () => props.status)
      ]),
      props.description && h("p", { class: "ui-subtitle" }, props.description),
      props.meta.length > 0 && h("div", { class: "ui-resource-card__meta" }, props.meta.map((item) => h("span", item))),
      slots.default?.()
    ])
  }
}

export const uiComponents = {
  UiAlert,
  UiBadge,
  UiButton,
  UiCard,
  UiFormField,
  UiResourceCard
}
