import type {StorybookConfig} from "@storybook/react-vite";

const config: StorybookConfig = {
    stories: [
        "../stories/**/*.mdx",
        "../stories/**/*.stories.@(js|jsx|ts|tsx)",
        "../javascript/components/*.stories.@(js|jsx|ts|tsx)"
    ],

    addons: [
        "@storybook/addon-essentials",
        "@storybook/addon-interactions",
        "@storybook/addon-mdx-gfm",
        "@chromatic-com/storybook"
    ],

    framework: {
        name: "@storybook/react-vite",
        options: {}
    },

    docs: {},

    typescript: {
        reactDocgen: "react-docgen-typescript"
    }
};

export default config;
