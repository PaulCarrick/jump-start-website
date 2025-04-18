// app/javascript/components/GenerateCells.stories.tsx

// Storybook test script to test GenerateCells

import {Meta, StoryObj} from "@storybook/react";
import GenerateCells from "../app/javascript/components/GenerateCells";
import {Section, Page} from "../app/javascript/types/dataTypes";
import {userEvent, within, expect} from "@storybook/test";

export default {
    title: "Components/GenerateCells",
    component: GenerateCells,
    parameters: {
        actions: {argTypesRegex: "^on.*"}, // Captures interactions
    },
} as Meta;

// Define a test Section and Page to pass as props
const testSection: Section = {
    section_name: "test-section",
    section_order: 1,
    content_type: "test-page",
    cells: [],
};

const testPage: Page = {
    name: "test-page",
    title: "Test Page",
    sections: [testSection],
};

export const Default: StoryObj<typeof GenerateCells> = {
    args: {
        page: testPage,
        section: "test-section",
        options: {},
    },
    play: async ({canvasElement}) => {
        const canvas = within(canvasElement);
        const templatesSelect = canvasElement.querySelector("#cellTemplates");

        if (!templatesSelect) throw new Error("Dropdown with ID 'cellTemplates' not found!");

        await userEvent.selectOptions(templatesSelect, "text-single");
        await expect(templatesSelect).toHaveValue("text-single");

        // Simulate typing in the description field
        await userEvent.type(
            canvas.getByPlaceholderText("Enter the text to be displayed in the text part of the section"),
            "Hello Storybook!"
        );

        // Verify that the text is displayed
        await expect(
            canvas.findByText("Hello Storybook!")
        ).resolves.toBeInTheDocument();

        // Click the "Generate Columns" button
        await userEvent.click(canvas.getByText("Generate Columns"));
        // Ensure the button click does not crash (e.g., a success message could be checked)
        await expect(canvas.getByText("Templates:")).toBeInTheDocument();
    },
};
