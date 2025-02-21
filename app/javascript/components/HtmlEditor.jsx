// /app/javascript/components/HtmlEditor.jsx

// Use Quill (a WYSIWYG Editor) to edit text

import React, {useState, useRef, useEffect} from "react";
import PropTypes from "prop-types";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";
import Quill from "quill";
import {html as beautifyHtml} from "js-beautify";

// Define a custom DivBlot
const Block = Quill.import("blots/block");

class DivBlot extends Block {
  static create(value) {
    let node = super.create();
    if (value && value.backgroundColor) {
      node.style.backgroundColor = value.backgroundColor;
    }
    return node;
  }

  static formats(node) {
    return {
      backgroundColor: node.style.backgroundColor || null,
    };
  }

  format(name, value) {
    if (name === "backgroundColor" && value) {
      this.domNode.style.backgroundColor = value;
    }
    else {
      super.format(name, value);
    }
  }
}

DivBlot.blotName = "div";
DivBlot.tagName  = "div";
Quill.register(DivBlot);

const HtmlEditor = ({
                      id = "",
                      value = "",
                      placeholder = "Enter text here...",
                      onChange = null,
                      onBlur = null,
                      noSwitchButton = false,
                    }) => {
  const [isHtmlView, setIsHtmlView]       = useState(false); // Toggle for raw HTML view
  const [editorContent, setEditorContent] = useState(value || ""); // Store editor content
  const quillRef                          = useRef(null);

  // Toolbar configuration to include color, background, and custom div option
  const toolbarOptions = [
    [{ font: [] }], // Font dropdown
    [{ size: [] }], // Font size dropdown
    ["bold", "italic", "underline", "strike"], // Formatting buttons
    [{ color: [] }, { background: [] }], // Text and background colors
    [{ script: "sub" }, { script: "super" }], // Subscript / superscript
    [{ header: [1, 2, 3, 4, 5, 6, false] }], // Header options
    [{ list: "ordered" }, { list: "bullet" }], // Lists
    [{ align: [] }], // Text alignment
    ["link", "image", "blockquote", "code-block"], // Additional options
    ["clean"], // Remove formatting
    ["div"], // Add custom div option
  ];

  useEffect(() => {
    if (quillRef.current) {
      const quill = quillRef.current.getEditor();

      // Add handler for background color
      quill.getModule("toolbar").addHandler("backgroundColor", (value) => {
        const range = quill.getSelection();
        if (range) {
          quill.format("backgroundColor", value);
        }
      });

      // Add handler for the 'div' button
      quill.getModule("toolbar").addHandler("div", () => {
        const range = quill.getSelection();
        if (range) {
          quill.insertEmbed(range.index, "div", { backgroundColor: "white" });
        }
      });
    }
  }, []);

  const toggleView = () => {
    if (isHtmlView) {
      // Switching back to Quill editor
      const quill = quillRef.current?.getEditor();

      if (quill)
        quill.clipboard.dangerouslyPasteHTML(editorContent); // Update Quill with the raw HTML
    }
    else {
      // Switching to HTML view
      const quill = quillRef.current?.getEditor();

      if (quill)
        setEditorContent(prettyPrintHtml(quill.root.innerHTML));
    }

    setIsHtmlView(!isHtmlView);
  };

  function prettyPrintHtml(html) {
    if (!html) return "";

    let formattedHtml = beautifyHtml(html, {
      indent_size: 2,
      wrap_attributes: "force-expand-multiline",
      wrap_line_length: 80,
      preserve_newlines: true,
      max_preserve_newlines: 1,
      indent_inner_html: true,
      end_with_newline: true,
      inline: []
    });

    // Define the tags we want to force onto separate lines
    const blockTags = ["p", "div", "a"];

    formattedHtml = formattedHtml.replace(
        new RegExp(`(<(${blockTags.join("|")})(\\s[^>]*)?>)`, "g"),
        "\n  $1\n"
    );

    formattedHtml = formattedHtml.replace(
        new RegExp(`(</(${blockTags.join("|")})>)`, "g"),
        "\n$1\n"
    );

    formattedHtml = formattedHtml.replace(/\n\s*\n/g, "\n");

    return formattedHtml.trim();
  }

  const handleChange = (content) => {
    setEditorContent(content); // Keep local state updated

    if (typeof onChange === "function") {
      onChange(content, id);
    }
    else if (onChange && typeof onChange === "string") {
      const callable = new Function("editorContent", "id", onChange);
      callable(content, id);
    }
  };

  const handleBlur = () => {
    const quill   = quillRef.current?.getEditor();
    const content = quill?.root.innerHTML;

    if (typeof onBlur === "function") {
      onBlur(content, id);
    }
    else if (onBlur && typeof onBlur === "string") {
      const callable = new Function("editorContent", "id", onBlur);
      callable(content, id);
    }
  };

  return (
      <div>
        {isHtmlView && !noSwitchButton ? (
            <textarea
                value={editorContent}
                onChange={(e) => setEditorContent(e.target.value)}
                onBlur={handleBlur}
                className="form-control"
                placeholder="Edit raw HTML here"
                rows={10}
            />
        ) : (
             <ReactQuill
                 ref={quillRef}
                 theme="snow"
                 id={id}
                 value={editorContent}
                 onChange={handleChange}
                 onBlur={handleBlur}
                 modules={{ toolbar: toolbarOptions }}
                 className="form-control"
                 placeholder={placeholder}
             />
         )}
        {!noSwitchButton && (
            <div className="row align-items-center">
              <div className="flex-container">
                {isHtmlView ? (
                    <button type="button" onClick={toggleView} className="btn btn-good mt-2 mb-2">
                      Switch to Editor View
                    </button>
                ) : (
                     <button type="button" onClick={toggleView} className="btn btn-bad mt-2 mb-2">
                       Switch to HTML View **
                     </button>
                 )
                }
                <span className="ms-4 mt-2">
                ** HTML View should only be used by users who are familiar with HTML
              </span>
              </div>
            </div>
        )}
      </div>
  );
};

HtmlEditor.propTypes = {
  id:             PropTypes.string.isRequired,
  value:          PropTypes.string,
  placeholder:    PropTypes.string,
  onChange:       PropTypes.oneOfType([PropTypes.func, PropTypes.string]),
  onBlur:         PropTypes.oneOfType([PropTypes.func, PropTypes.string]),
  noSwitchButton: PropTypes.bool
};

export default HtmlEditor;
