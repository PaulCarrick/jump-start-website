// /app/javascript/components/PostList.jsx
// noinspection JSUnresolvedVariable

import PropTypes from 'prop-types';
import React, { useEffect, useState } from 'react';
import moment from 'moment';
import PostEditor from './PostEditor';
import CommentEditor from './CommentEditor';

const PostList = ({
                    user = {
                      id:        2,
                      name:      "Unknown",
                      email:     "guest@jumpstartserver.com",
                      logged_in: false,
                      access:    "blogs"
                    },
                    blog_type = "Personal" }) => {
  const [posts, setPosts] = useState([]);
  const [meta, setMeta] = useState({ totalPages: 1, currentPage: 1, totalCount: 0 });
  const [currentPage, setCurrentPage] = useState(1);
  const [searchFields, setSearchFields] = useState({
    title: '',
    author: '',
    content: '',
  });
  const [showPostEditor, setShowPostEditor] = useState(false);
  const [showCommentEditor, setShowCommentEditor] = useState(false);
  const [editingPost, setEditingPost] = useState(null);
  const [commentPost, setCommentPost] = useState(null);
  const [editingComment, setEditingComment] = useState(null);

  const fetchPosts = (page = 1) => {
    const queryParams = Object.entries(searchFields)
      .filter(([_, value]) => value.trim() !== '')
      .map(
        ([field, value]) => `q[${field}_cont]=${encodeURIComponent(value)}`
      )
      .join('&');
    const url = `/api/v1/blog_posts?include_comments=true&blog_type=${blog_type}&visibility=${user.logged_in ? "Private" : "Public"}&page=${page}&limit=3${queryParams ? `&${queryParams}` : ''}`;

    fetch(url)
      .then((response) => {
        const totalPages = parseInt(response.headers.get('total-Pages'), 10) || 1;
        const currentPage = parseInt(response.headers.get('current-page'), 10) || 1;
        const totalCount = parseInt(response.headers.get('total-Count'), 10) || 0;

        setMeta({
          totalPages,
          currentPage,
          totalCount,
        });
        return response.json();
      })
      .then((data) => {
        if (data.blog_posts) {
          setPosts(data.blog_posts);
        } else {
          setPosts([]);
        }
      })
      .catch((error) => console.error('Error fetching posts:', error));
  };

  useEffect(() => {
    fetchPosts(currentPage);
  }, [currentPage]);

  const DateTimeDisplay = ({ dateTime }) => {
    return moment(dateTime).local().format('MMM Do YYYY HH:mm');
  };

  const openPostEditor = (post = null) => {
    setEditingPost(post);
    setShowPostEditor(true);
  };

  const closePostEditor = () => {
    setEditingPost(null);
    setShowPostEditor(false);
  };

  const openCommentEditor = (post, comment = null) => {
    setCommentPost(post);
    setEditingComment(comment);
    setShowCommentEditor(true);
  };

  const closeCommentEditor = () => {
    setCommentPost(null);
    setEditingComment(null);
    setShowCommentEditor(false);
  };

  const handleSearch = (e) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchPosts(1);
  };

  const handlePostDelete = (postId) => {
    const confirmDelete = window.confirm("Are you sure you want to delete this post?");
    if (!confirmDelete) {
      return;
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

    fetch(`/api/v1/blog_posts/${postId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
      },
    })
      .then((response) => {
        if (response.ok) {
          console.log('Post deleted successfully!');
          fetchPosts(currentPage);
        } else {
          console.error('Failed to delete post');
        }
      })
      .catch((error) => console.error('Error:', error));
  };

  const handleCommentDelete = (commentId) => {
    const confirmDelete = window.confirm("Are you sure you want to delete this comment?");
    if (!confirmDelete) {
      return;
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

    fetch(`/api/v1/post_comments/${commentId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json',
      },
    })
      .then((response) => {
        if (response.ok) {
          console.log('Comment deleted successfully!');
          fetchPosts(currentPage);
        } else {
          console.error('Failed to delete comment');
        }
      })
      .catch((error) => console.error('Error:', error));
  };

  const changePage = (newPage) => {
    if (newPage > 0 && newPage <= meta.totalPages) {
      setCurrentPage(newPage);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setSearchFields((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  return (
    <div>
      <h1 className="text-dark">Blog Entries</h1>
      <div className="rounded-box p-3 mb-3">
        {posts.map((post) => (
          <div key={post.id} className="ps-3 mb-3">
            <div className="row align-items-center">
              <div className="col-8">
                <h2>{post.title}</h2>
                {DateTimeDisplay({ dateTime: post.posted })} - {post.author}
              </div>
              <div className="col-4 text-end">
                {user.logged_in && (
                  <button
                    onClick={() => openCommentEditor(post)}
                    className="btn-link me-2"
                  >
                    Comment
                  </button>
                )}
                {post.author === user.name && (
                  <>
                    <button
                      onClick={() => openPostEditor(post)}
                      className="btn-link me-2"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => handlePostDelete(post.id)}
                      className="btn-link me-2"
                      style={{ color: 'red' }}
                    >
                      Delete
                    </button>
                  </>
                )}
              </div>
            </div>
            <div className="row ps-5 pt-3">
              <div className="col-lg-12">
                <div dangerouslySetInnerHTML={{ __html: post.content }}></div>
              </div>
            </div>
            {post.post_comments && post.post_comments.length > 0 && (
              <div className="row ps-5 pt-3">
                <div className="col-lg-12">
                  <h5>Comments</h5>
                  {post.post_comments.map((comment) => (
                    <div
                      key={comment.id}
                      className="ps-3 mb-3"
                      style={{
                        marginLeft: "1em",
                        borderLeft: "2px solid #ddd",
                        paddingLeft: "1em",
                      }}
                    >
                      <div className="row align-items-center">
                        <div className="col-9">
                          <h6>{comment.title}</h6>
                          {DateTimeDisplay({ dateTime: comment.posted })} - {comment.author}
                        </div>
                        <div className="col-3 text-end">
                          {user.logged_in && comment.author === user.name && (
                            <button
                              onClick={() => openCommentEditor(post, comment)}
                              className="btn-link me-2"
                            >
                              Edit
                            </button>
                          )}
                          {comment.author === user.name && (
                            <button
                              onClick={() => handleCommentDelete(comment.id)}
                              className="btn-link me-2"
                              style={{ color: 'red' }}
                            >
                              Delete
                            </button>
                          )}
                        </div>
                      </div>
                      <div className="row ps-3 pt-2">
                        <div className="col-lg-12">
                          <div dangerouslySetInnerHTML={{ __html: comment.content }}></div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
      {(!showPostEditor && !showCommentEditor) ? (
        <>
          <div className="row">
            <div className="col-2">
              {((user.access === 'blogs') || (user.access === 'admin') || (user.access === 'super')) && (
                <button onClick={() => openPostEditor()} className="btn btn-primary">
                  Add Post
                </button>
              )}
            </div>
            <div className="col-10">
              <div className="mb-3 d-flex justify-content-end align-items-center">
                <button
                  onClick={() => changePage(currentPage - 1)}
                  className="btn-link me-2"
                  disabled={currentPage === 1}
                >
                  Previous
                </button>
                <span className="me-2">
                  Page {meta.currentPage} of {meta.totalPages}
                </span>
                <button
                  onClick={() => changePage(currentPage + 1)}
                  className="btn-link me-2"
                  disabled={currentPage >= meta.totalPages}
                >
                  Next
                </button>
              </div>
            </div>
          </div>
          <div className="mt-3 rounded-box">
            <form onSubmit={handleSearch}>
              <div className="row p-3">
                <div className="col-3">
                  <label htmlFor="title" className="form-label">
                    Title
                  </label>
                  <input
                    type="text"
                    id="title"
                    name="title"
                    className="form-control"
                    value={searchFields.title}
                    onChange={handleInputChange}
                    placeholder="Search by title"
                  />
                </div>
                <div className="col-1"></div>
                <div className="col-3">
                  <label htmlFor="author" className="form-label">
                    Author
                  </label>
                  <input
                    type="text"
                    id="author"
                    name="author"
                    className="form-control"
                    value={searchFields.author}
                    onChange={handleInputChange}
                    placeholder="Search by author"
                  />
                </div>
                <div className="col-1"></div>
                <div className="col-3">
                  <label htmlFor="content" className="form-label">
                    Content
                  </label>
                  <input
                    type="text"
                    id="content"
                    name="content"
                    className="form-control"
                    value={searchFields.content}
                    onChange={handleInputChange}
                    placeholder="Search by content"
                  />
                </div>
                <div className="row mt-3">
                  <div className="col-1">
                    <button type="submit" className="btn btn-primary">
                      Search
                    </button>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </>
      ) : showPostEditor ? (
        <div className="rounded-box p-3">
          <PostEditor closeEditor={closePostEditor} blog_type={blog_type} user={user} post={editingPost} />
        </div>
      ) : (
        showCommentEditor && (
          <div className="rounded-box p-3">
            <CommentEditor
              closeEditor={closeCommentEditor}
              user={user}
              post={commentPost}
              comment={editingComment}
            />
          </div>
        )
      )}
    </div>
  );
};

PostList.propTypes = {
  user: PropTypes.shape({
                          id: PropTypes.number.isRequired,
                          name: PropTypes.string.isRequired,
                          email: PropTypes.string,
                          logged_in: PropTypes.bool.isRequired,
                          access: PropTypes.oneOf(['blogs', 'admin', 'super']).isRequired,
                        }).isRequired,
  blog_type: PropTypes.oneOf(['Personal', 'Professional']).isRequired
};

export default PostList;
