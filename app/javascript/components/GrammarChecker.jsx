// /app/javascript/components/GrammarChecker.jsx

// "Check spelling and grammar" under the admin's text editor. The editor's
// text is sent to LanguageTool (through /admin/grammar_check); each problem is
// underlined in the editor (red for spelling, blue for grammar) and listed
// below it with its suggestions. Choosing a suggestion changes the text in
// place, keeping its formatting; nothing is saved until the editor is.

import React, { useState, useEffect, useRef, useCallback } from "react";
import PropTypes from "prop-types";
import { siteFetch } from "../sitePath";

// A picture or other embedded object counts as one character in the editor.
const OBJECT_CHARACTER = "￼";

function editorText(quill) {
  return quill
    .getContents()
    .ops.map((operation) => (typeof operation.insert === "string" ? operation.insert : OBJECT_CHARACTER))
    .join("");
}

function overlaps(first, second) {
  return first.offset < second.offset + second.length && second.offset < first.offset + first.length;
}

// Where the text from index to index + length is on the screen: one box per
// line it runs over. Measured from the page itself, because Quill's own
// getBounds is off when the editor sits in a scaled or offset layout.
function textRects(quill, index, length) {
  try {
    const [startLeaf, startOffset] = quill.getLeaf(index);
    const [endLeaf, endOffset] = quill.getLeaf(index + length);
    if (startLeaf?.domNode?.nodeType === Node.TEXT_NODE && endLeaf?.domNode?.nodeType === Node.TEXT_NODE) {
      const range = document.createRange();
      range.setStart(startLeaf.domNode, Math.min(startOffset, startLeaf.domNode.length));
      range.setEnd(endLeaf.domNode, Math.min(endOffset, endLeaf.domNode.length));
      return Array.from(range.getClientRects()).filter((rect) => rect.width >= 1);
    }
  } catch (_error) {
    // Fall back to the editor's own measure below.
  }
  const bounds = quill.getBounds(index, length);
  if (!bounds) return [];
  const container = quill.container.getBoundingClientRect();
  return [{ left: container.left + bounds.left, bottom: container.top + bounds.top + bounds.height, width: bounds.width }];
}

const GrammarChecker = ({ quillRef }) => {
  const [problems, setProblems] = useState(null);
  const [status, setStatus] = useState("");
  const [busy, setBusy] = useState(false);
  const [, setVersion] = useState(0);
  const problemsRef = useRef(null);
  const applyingRef = useRef(false);
  const layerRef = useRef(null);

  problemsRef.current = problems;

  const editor = useCallback(() => quillRef.current?.getEditor?.() ?? null, [quillRef]);

  // Underlines, drawn over the editor (they are never part of the text).
  const draw = useCallback(() => {
    const quill = editor();
    if (!quill) return;
    // The layer sits beside the editor box, not inside it: the admin's styles
    // enlarge that box with a CSS transform, which would stretch anything
    // drawn in it.
    let layer = layerRef.current;
    if (!layer || !layer.isConnected) {
      layer = document.createElement("div");
      layer.className = "grammar-layer";
      layer.setAttribute("aria-hidden", "true");
      const host = quill.container.parentElement;
      host.classList.add("grammar-host");
      host.append(layer);
      layerRef.current = layer;
    }
    layer.replaceChildren();
    const length = quill.getLength();
    const origin = layer.getBoundingClientRect();
    // Words scrolled out of the editor's view get no underline.
    const view = quill.root.getBoundingClientRect();
    (problemsRef.current || []).forEach((problem, index) => {
      if (problem.offset + problem.length > length) return;
      textRects(quill, problem.offset, problem.length).forEach((rect) => {
        if (rect.bottom < view.top + 2 || rect.bottom > view.bottom + 2) return;
        const mark = document.createElement("span");
        mark.className = `grammar-mark is-${problem.kind}`;
        mark.dataset.problem = String(index);
        mark.style.left = `${rect.left - origin.left}px`;
        mark.style.top = `${rect.bottom - origin.top - 2}px`;
        mark.style.width = `${rect.width}px`;
        layer.append(mark);
      });
    });
  }, [editor]);

  useEffect(() => {
    draw();
  }, [problems, draw]);

  // Typing after a check makes the positions stale: clear them and say so.
  useEffect(() => {
    const quill = editor();
    if (!quill) return undefined;
    const changed = () => {
      if (applyingRef.current || !problemsRef.current?.length) return;
      setProblems(null);
      setStatus("The text changed. Check it again to see what is left.");
    };
    const redraw = () => draw();
    quill.on("text-change", changed);
    quill.root.addEventListener("scroll", redraw);
    window.addEventListener("resize", redraw);
    return () => {
      quill.off("text-change", changed);
      quill.root.removeEventListener("scroll", redraw);
      window.removeEventListener("resize", redraw);
      layerRef.current?.remove();
    };
  }, [editor, draw]);

  const check = async () => {
    const quill = editor();
    if (!quill) return;
    const text = editorText(quill);
    if (!text.trim()) {
      setProblems(null);
      setStatus("There is no text to check.");
      return;
    }
    setBusy(true);
    setStatus("Checking…");
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      const response = await siteFetch("/admin/grammar_check", {
        method: "POST",
        headers: { "Content-Type": "application/json", Accept: "application/json", "X-CSRF-Token": token },
        body: JSON.stringify({ text }),
      });
      const result = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(result.error || "The text could not be checked.");
      // The text may have changed while it was being checked.
      if (editorText(quill) !== text) {
        setProblems(null);
        setStatus("The text changed while it was being checked. Check it again.");
        return;
      }
      const found = result.problems || [];
      setProblems(found);
      setStatus(
        found.length === 0
          ? "No spelling or grammar problems found."
          : `${found.length} possible ${found.length === 1 ? "problem" : "problems"} found. Underlined in red: spelling; in blue: grammar.`,
      );
    } catch (error) {
      setProblems(null);
      setStatus(error.message);
    } finally {
      setBusy(false);
    }
  };

  const wordOf = (problem) => {
    const quill = editor();
    return quill ? editorText(quill).substr(problem.offset, problem.length) : "";
  };

  const show = (problem) => {
    const quill = editor();
    if (!quill) return;
    quill.setSelection(problem.offset, problem.length, "silent");
    quill.scrollSelectionIntoView?.();
    setVersion((version) => version + 1);
  };

  const finish = (remaining) => {
    setProblems(remaining);
    setStatus(
      remaining.length === 0
        ? "All done. Save to keep the changes."
        : `${remaining.length} possible ${remaining.length === 1 ? "problem" : "problems"} left.`,
    );
  };

  const apply = (problem, replacement) => {
    const quill = editor();
    if (!quill) return;
    applyingRef.current = true;
    try {
      const formats = quill.getFormat(problem.offset, Math.max(problem.length, 1));
      quill.deleteText(problem.offset, problem.length, "user");
      if (replacement) quill.insertText(problem.offset, replacement, formats, "user");
    } finally {
      applyingRef.current = false;
    }
    const shift = replacement.length - problem.length;
    finish(
      problemsRef.current
        .filter((other) => other !== problem && !overlaps(other, problem))
        .map((other) => (other.offset > problem.offset ? { ...other, offset: other.offset + shift } : other)),
    );
  };

  const ignore = (problem) => {
    finish(problemsRef.current.filter((other) => other !== problem));
  };

  const ignoreWord = (problem) => {
    const word = wordOf(problem);
    finish(problemsRef.current.filter((other) => !(other.kind === "spelling" && wordOf(other) === word)));
  };

  return (
    <div className="grammar-check">
      <div className="grammar-check-bar">
        <button type="button" className="btn btn-outline-primary btn-sm" onClick={check} disabled={busy}>
          {busy ? "Checking…" : "Check spelling and grammar"}
        </button>
        <span className="grammar-check-status" role="status" aria-live="polite">
          {status}
        </span>
      </div>
      {problems?.length > 0 && (
        <ol className="grammar-problems">
          {problems.map((problem, index) => {
            const word = wordOf(problem);
            const repeated = problem.kind === "spelling" && problems.filter((other) => other.kind === "spelling" && wordOf(other) === word).length > 1;
            return (
              <li key={`${problem.offset}-${problem.rule}-${index}`} className={`grammar-problem is-${problem.kind}`}>
                <div className="grammar-problem-head">
                  <button type="button" className="grammar-problem-word" onClick={() => show(problem)} title="Show it in the text">
                    {word.trim() ? `“${word}”` : "(a space)"}
                  </button>
                  <span className="grammar-problem-kind">{problem.kind === "spelling" ? "Spelling" : "Grammar"}</span>
                </div>
                <p className="grammar-problem-message">{problem.message}</p>
                <div className="grammar-problem-actions">
                  {problem.replacements.map((replacement) => (
                    <button
                      type="button"
                      key={replacement}
                      className="btn btn-sm btn-outline-success"
                      onClick={() => apply(problem, replacement)}
                      title={`Change “${word}” to “${replacement}”`}
                    >
                      {replacement.trim() ? replacement : "(remove)"}
                    </button>
                  ))}
                  <button type="button" className="btn btn-sm btn-link" onClick={() => ignore(problem)}>
                    Ignore
                  </button>
                  {repeated && (
                    <button type="button" className="btn btn-sm btn-link" onClick={() => ignoreWord(problem)}>
                      Ignore all “{word}”
                    </button>
                  )}
                </div>
              </li>
            );
          })}
        </ol>
      )}
    </div>
  );
};

GrammarChecker.propTypes = {
  quillRef: PropTypes.shape({ current: PropTypes.any }).isRequired,
};

export default GrammarChecker;
