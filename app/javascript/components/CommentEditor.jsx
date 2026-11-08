import { siteFetch } from "../sitePath";
import EnabledSwitch from "./EnabledSwitch";
// /app/javascript/components/CommentEditor.jsx
// noinspection JSUnusedLocalSymbols

import React, { useState } from 'react';
import PropTypes from 'prop-types';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';

// Writes a new comment, or edits one when `comment` is given. The server sets
// the author, the date and who wrote it, so they are only shown here.
const CommentEditor = ({
                           user = {
                               name: 'Visitor'
                           },
                           post =  {
                               visibility: 'Public'
                           },
                           comment = null,
                           blog_type = "Personal",
                           closeEditor = null
                       }) => {
  const [blogPostId] = useState(post?.id || null);
  const [title, setTitle] = useState(comment?.title || ''); // Use existing title if editing
  const [content, setContent] = useState(comment?.content || ''); // Use existing content if editing
  const [enabled, setEnabled] = useState(comment?.enabled !== false);
  const [error, setError] = useState(null);
  const author = comment?.author || user?.name || 'Visitor';
  const isAdministrator = (user?.access === 'admin') || (user?.access === 'super');

  const handleSubmit = () => {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    const url = comment
      ? `/api/v1/post_comments/${comment.id}` // Include the ID for updates
      : '/api/v1/post_comments'; // Create new comment
    const fields = { blog_post_id: blogPostId, title, content };

    if (isAdministrator) fields.enabled = enabled;

    setError(null);
    siteFetch(url, {
      method: comment ? 'PUT' : 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({ post_comment: fields }),
    })
      .then(async (response) => {
        if (response.ok) {
          if (closeEditor) closeEditor();

          // Show the blog again with the new or changed comment.
          window.location.reload();
          return;
        }

        const payload = await response.json().catch(() => ({}));
        const message = [].concat(payload.errors || payload.error || 'The comment could not be saved.').join(', ');

        setError(message);
      })
      .catch(() => setError('The comment could not be saved. Please try again.'));
  };

  // noinspection JSValidateTypes
    return (
    <div>
      <h1>{comment ? 'Edit Comment' : 'Create a New Comment'}</h1>
      {error && <div className="alert alert-danger">{error}</div>}
      <input
        type="text"
        placeholder="Title"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        className="form-control mb-2"
      />
      <input
        type="text"
        placeholder="Author"
        value={author}
        className="form-control mb-2"
        readOnly
      />
      {isAdministrator && <EnabledSwitch enabled={enabled} onChange={setEnabled} />}
      <ReactQuill value={content} onChange={setContent} />
      <div className="mt-3">
        <button type="button" onClick={handleSubmit} className="btn btn-primary me-2">
          {comment ? 'Update' : 'Submit'}
        </button>
        <button type="button" onClick={closeEditor} className="btn btn-secondary">
          Cancel
        </button>
      </div>
    </div>
  );
};

CommentEditor.propTypes = {
  user: PropTypes.shape({
                          name: PropTypes.string,
                          access: PropTypes.string,
                        }),
  post: PropTypes.shape({
                          id: PropTypes.number.isRequired,
                        }).isRequired,
  comment: PropTypes.shape({
                             id: PropTypes.number.isRequired,
                             title: PropTypes.string,
                             content: PropTypes.string,
                             author: PropTypes.string,
                             enabled: PropTypes.bool,
                           }),
  closeEditor: PropTypes.func.isRequired,
  blog_type: PropTypes.string,
};

export default CommentEditor;
