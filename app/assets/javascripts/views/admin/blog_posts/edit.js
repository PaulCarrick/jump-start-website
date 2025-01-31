// /app/javascript/views/admin/blog_posts/edit.js

function validate(form) {
  const contentField = document.getElementById("blog_post_content");
  let isValid            = false;

  if (!contentField) return isValid;

  isValid = checkHtml(contentField);

  return isValid;
}
