// /app/javascript/components/PostEditor.jsx
// noinspection JSUnusedLocalSymbols

import React, {useState} from 'react';
import PropTypes from 'prop-types';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';

const PostEditor = ({
                        user = {
                            name: 'Unknown'
                        },
                        post =  {
                            visibility: 'Public'
                        },
                        blog_type = "Personal",
                        closeEditor = null }) => {
  const [ title, setTitle ] = useState(post?.title || '');
  const [ author, setAuthor ] = useState(user.name);
  const [ content, setContent ] = useState(post?.content || '');
  const [ posted, setPosted ] = useState(post?.posted || new Date().toISOString());
  const [ visibility, setVisibility ] = useState(post?.visibility || 'public');

  const handleSubmit = () => {
    const getCsrfToken = () => {
      return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    };

    const url = post
      ? `/api/v1/blog_posts/${post.id}` // Include the ID for updates
      : '/api/v1/blog_posts'; // Create new post

    const method = post ? 'PUT' : 'POST'; // Use PUT for updates, POST for new

    fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getCsrfToken(), // Include the CSRF token here
      },
      body: JSON.stringify({
                             blog_post: {
                               title,
                               author,
                               blog_type,
                               content,
                               posted,
                               visibility
                             }, // Include all fields
                           }),
    })
      .then((response) => {
        if (response.ok) {
          console.log('Post saved successfully!');
          // noinspection JSValidateTypes
            closeEditor(); // Close the editor on success
          window.location.href = '/blogs'; // Redirect to the blogs page
        }
        else {
          console.error('Failed to save post');
        }
      })
      .catch((error) => console.error('Error:', error));
  };

  // noinspection JSValidateTypes
    return (
    <div>
      <h1>{post ? 'Edit Post' : 'Create a New Post'}</h1>
      <input
        type="text"
        placeholder="Title"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        className="form-control mb-2"
      />
      <input
        type="hidden"
        value={blog_type}
      />
      <input
        type="text"
        placeholder="Author"
        value={author}
        className="form-control mb-2"
        readOnly
      />
      <input
        type="hidden"
        value={posted} // Hidden input to hold the DateTime value
        readOnly
      />
      <div className="mb-2">
        <label htmlFor="visibility" className="form-label">Visibility</label>
        <select
          id="visibility"
          value={visibility}
          onChange={(e) => setVisibility(e.target.value)}
          className="form-control"
          style={{maxWidth: '6em'}}
        >
          <option value="">Select visibility</option>
          <option value="Public">Public</option>
          <option value="Private">Private</option>
        </select>
      </div>
      <ReactQuill value={content} onChange={setContent}/>
      <div className="mt-3">
        <button onClick={handleSubmit} className="btn btn-primary me-2">
          {post ? 'Update' : 'Submit'}
        </button>
        <button onClick={closeEditor} className="btn btn-secondary">
          Cancel
        </button>
      </div>
    </div>
  );
};

PostEditor.propTypes = {
  user: PropTypes.shape({
                          name: PropTypes.string.isRequired
                        }).isRequired,
  post: PropTypes.shape({
                          id: PropTypes.number,
                          title: PropTypes.string,
                          content: PropTypes.string,
                          posted: PropTypes.string,
                          visibility: PropTypes.oneOf([ 'public', 'private' ]),
                        }),
  blog_type: PropTypes.oneOf([ 'Personal', 'Professional' ]).isRequired,
  closeEditor: PropTypes.func.isRequired
};

export default PostEditor;
