// /app/javascript/components/CommentEditor.jsx
// noinspection JSUnusedLocalSymbols

import React, { useState } from 'react';
import PropTypes from 'prop-types';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';

const CommentEditor = ({
                           user = {
                               name: 'Unknown'
                           },
                           post =  {
                               visibility: 'Public'
                           },
                           blog_type = "Personal",
                           closeEditor = null
                       }) => {
  const [blogPostId, setBlogPostId] = useState(post?.id || null);
  const [title, setTitle] = useState(comment?.title || ''); // Use existing title if editing
  const [author, setAuthor] = useState(user.name); // Always set to the current user
  const [content, setContent] = useState(comment?.content || ''); // Use existing content if editing
  const [posted, setPosted] = useState(comment?.posted || new Date().toISOString()); // Set posted if editing, otherwise use now

  const handleSubmit = () => {
    const getCsrfToken = () => {
      return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    };

    const url = comment
      ? `/api/v1/post_comments/${comment.id}` // Include the ID for updates
      : '/api/v1/post_comments'; // Create new comment

    const method = comment ? 'PUT' : 'POST'; // Use PUT for updates, POST for new

    fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getCsrfToken(), // Include the CSRF token here
      },
      body: JSON.stringify({
        post_comment: { blog_post_id: blogPostId, title, author, content, posted }, // Include all fields
      }),
    })
      .then((response) => {
        if (response.ok) {
          console.log('Comment saved successfully!');

          if (closeEditor) closeEditor();

          // Redirect to the parent blogs post or refresh comments
          window.location.href = `/blog`;
        } else {
          console.error('Failed to save comment');
        }
      })
      .catch((error) => console.error('Error:', error));
  };

  // noinspection JSValidateTypes
    return (
    <div>
      <h1>{comment ? 'Edit Comment' : 'Create a New Comment'}</h1>
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
      <ReactQuill value={content} onChange={setContent} />
      <div className="mt-3">
        <button onClick={handleSubmit} className="btn btn-primary me-2">
          {comment ? 'Update' : 'Submit'}
        </button>
        <button onClick={closeEditor} className="btn btn-secondary">
          Cancel
        </button>
      </div>
    </div>
  );
};

CommentEditor.propTypes = {
  user: PropTypes.shape({
                          name: PropTypes.string.isRequired,
                        }).isRequired,
  post: PropTypes.shape({
                          id: PropTypes.number.isRequired,
                        }).isRequired,
  comment: PropTypes.shape({
                             id: PropTypes.number.isRequired,
                             title: PropTypes.string.isRequired,
                             content: PropTypes.string.isRequired,
                             posted: PropTypes.string.isRequired,
                           }).isRequired,
  closeEditor: PropTypes.func.isRequired,
  blog_type: PropTypes.string,
};

export default CommentEditor;
