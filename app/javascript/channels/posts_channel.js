import consumer from "./consumer"

consumer.subscriptions.create("PostsChannel", {
  connected() {
    console.log("connected to posts channel")
  },

  disconnected() {
    console.log("disconnected from posts channel1111")
  },

  received(data) {
    const postContainer = document.getElementById("posts")
    if (postContainer) {
      postContainer.insertAdjacentHTML("afterbegin", createPostHtml(data))
    }
  }
});

function createPostHtml(post) {
  return `
       <div id="post_${post.id}" class="post p-2 mb-2 border rounded">
          <a href="/posts/${post.id}" data-turbo-frame="_top">
            ${escapeHtml(post.title)}
          </a>
          
          <p>${escapeHtml(truncate(post.body, 150))}</p>
          
          <p>${escapeHtml(post.user.fio)}</p>
          
          <p>${escapeHtml(post.region.name)}</p>
       </div>
    `
}

function escapeHtml(unsafe) {
  return unsafe
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
}

function truncate(str, length) {
  if (str.length > length) {
    return str.substring(0, length) + "..."
  }
  return str
}
