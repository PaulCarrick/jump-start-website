// /app/javascript/views/admin/blog_posts/index.js

document.addEventListener("click", function (event) {
  if (event.target.matches("[data-action='expand-content']")) {
    event.preventDefault();

    const postId = event.target.dataset.postId;
    const contentSpan = document.querySelector(`#post-content-${postId}`);

    contentSpan.innerHTML = event.target.dataset.content;
    event.target.style.display = "none";
  }
});
