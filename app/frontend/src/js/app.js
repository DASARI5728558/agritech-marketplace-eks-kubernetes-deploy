const STORAGE_KEY = "agritech-premium-cart-v1";

const byId = (id) => document.getElementById(id);

const money = (value) =>
  new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0
  }).format(value);

const escapeHtml = (value = "") =>
  String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");

function assetUrl(path = "") {
  if (!path) return "";
  if (/^(https?:|data:|\/)/i.test(path)) return path;

  const page = document.body.dataset.page || "home";
  return page === "home" ? path : `../${path}`;
}

function loadCart() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
  } catch {
    return [];
  }
}

const state = {
  filter: "all",
  search: "",
  cart: loadCart()
};

function getProducts() {
  return window.PRODUCTS || [];
}

function saveCart() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.cart));
  updateCartCount();
}

function updateCartCount() {
  const count = state.cart.reduce((sum, item) => sum + item.qty, 0);
  const el = byId("cartCount");

  if (el) {
    el.textContent = String(count);
  }
}

function showToast(message) {
  let toast = byId("toast");

  if (!toast) {
    toast = document.createElement("div");
    toast.id = "toast";
    toast.className = "toast";
    document.body.appendChild(toast);
  }

  toast.innerHTML = `
    <i class="fa-solid fa-circle-check"></i>
    <span>${escapeHtml(message)}</span>
  `;

  toast.classList.add("show");

  clearTimeout(showToast.timer);
  showToast.timer = setTimeout(() => {
    toast.classList.remove("show");
  }, 1900);
}

function renderProducts() {
  const grid = byId("productGrid");
  if (!grid) return;

  const query = state.search.trim().toLowerCase();

  const products = getProducts().filter((p) => {
    const matchesFilter = state.filter === "all" || p.crop === state.filter;

    const matchesSearch =
      !query ||
      p.name.toLowerCase().includes(query) ||
      p.crop.toLowerCase().includes(query) ||
      p.category.toLowerCase().includes(query) ||
      p.stage.toLowerCase().includes(query) ||
      p.description.toLowerCase().includes(query) ||
      p.ingredients.join(" ").toLowerCase().includes(query);

    return matchesFilter && matchesSearch;
  });

  if (!products.length) {
    grid.innerHTML = `
      <article class="card empty-state">
        <i class="fa-solid fa-magnifying-glass"></i>
        <h3>No products found</h3>
        <p>Try another crop, ingredient or product name.</p>
      </article>
    `;
    return;
  }

  grid.innerHTML = products
    .map(
      (p) => `
        <article class="card">
          <div class="card-image-wrap">
            <img
              class="card-image"
              src="${escapeHtml(assetUrl(p.image))}"
              alt="${escapeHtml(p.name)}"
              loading="lazy"
              onerror="this.onerror=null;this.src='${escapeHtml(p.fallback)}';"
            />

            <span class="card-icon">
              <i class="${escapeHtml(p.icon)}"></i>
            </span>

            <span class="badge">
              <i class="fa-solid fa-award"></i>
              ${escapeHtml(p.badge)}
            </span>
          </div>

          <div class="card-body">
            <div class="card-meta">
              <span class="tag">
                <i class="fa-solid fa-seedling"></i>
                ${escapeHtml(p.crop)}
              </span>
              <span class="tag">
                <i class="fa-solid fa-calendar-check"></i>
                ${escapeHtml(p.stage)}
              </span>
            </div>

            <h3>${escapeHtml(p.name)}</h3>
            <p>${escapeHtml(p.description)}</p>

            <div class="card-foot">
              <div>
                <div class="price">${money(p.price)}</div>
                <div class="rating">
                  <i class="fa-solid fa-star"></i>
                  ${escapeHtml(p.rating)}
                </div>
              </div>

              <span class="tag">
                <i class="fa-solid fa-box-open"></i>
                Kit
              </span>
            </div>

            <div class="card-actions">
              <button class="card-btn secondary" data-action="details" data-id="${p.id}">
                <i class="fa-solid fa-eye"></i>
                Details
              </button>

              <button class="card-btn primary" data-action="add" data-id="${p.id}">
                <i class="fa-solid fa-cart-plus"></i>
                Add
              </button>
            </div>
          </div>
        </article>
      `
    )
    .join("");
}

function openModal(productId) {
  const modal = byId("productModal");
  const modalBody = byId("modalBody");

  if (!modal || !modalBody) return;

  const product = getProducts().find((p) => p.id === Number(productId));
  if (!product) return;

  modalBody.innerHTML = `
    <div class="modal-grid">
      <img
        class="modal-img"
        src="${escapeHtml(assetUrl(product.image))}"
        alt="${escapeHtml(product.name)}"
        onerror="this.onerror=null;this.src='${escapeHtml(product.fallback)}';"
      />

      <div class="modal-info">
        <span class="pill">
          <i class="${escapeHtml(product.icon)}"></i>
          ${escapeHtml(product.badge)}
        </span>

        <h2>${escapeHtml(product.name)}</h2>

        <p>${escapeHtml(product.description)}</p>

        <div class="detail-list">
          <p><strong>Crop:</strong> ${escapeHtml(product.crop)}</p>
          <p><strong>Stage:</strong> ${escapeHtml(product.stage)}</p>
          <p><strong>Category:</strong> ${escapeHtml(product.category)}</p>
          <p><strong>Ingredients:</strong> ${escapeHtml(product.ingredients.join(", "))}</p>
          <p><strong>Rating:</strong> <i class="fa-solid fa-star" style="color:#f6a800"></i> ${escapeHtml(product.rating)}</p>
          <p><strong>Price:</strong> ${money(product.price)}</p>
        </div>

        <div class="hero-actions">
          <button class="modal-action primary" data-action="add" data-id="${product.id}">
            <i class="fa-solid fa-cart-plus"></i>
            Add to cart
          </button>

          <button class="modal-action secondary" id="closeFromModal">
            <i class="fa-solid fa-xmark"></i>
            Close
          </button>
        </div>
      </div>
    </div>
  `;

  modal.classList.remove("hidden");
  modal.setAttribute("aria-hidden", "false");

  byId("closeFromModal")?.addEventListener("click", closeModal);

  modalBody.querySelector("[data-action='add']")?.addEventListener("click", (e) => {
    addToCart(e.currentTarget.dataset.id);
  });
}

function closeModal() {
  const modal = byId("productModal");

  if (modal) {
    modal.classList.add("hidden");
    modal.setAttribute("aria-hidden", "true");
  }
}

function addToCart(productId) {
  const product = getProducts().find((p) => p.id === Number(productId));
  if (!product) return;

  const existing = state.cart.find((item) => item.id === product.id);

  if (existing) {
    existing.qty += 1;
  } else {
    state.cart.push({
      id: product.id,
      name: product.name,
      price: product.price,
      image: product.image,
      fallback: product.fallback,
      icon: product.icon,
      crop: product.crop,
      qty: 1
    });
  }

  saveCart();
  showToast(`${product.name} added to cart`);
}

function bindHomeEvents() {
  byId("searchInput")?.addEventListener("input", (e) => {
    state.search = e.target.value;
    renderProducts();
  });

  byId("filterBar")?.addEventListener("click", (e) => {
    const btn = e.target.closest("[data-filter]");
    if (!btn) return;

    state.filter = btn.dataset.filter;

    document.querySelectorAll(".chip").forEach((chip) => {
      chip.classList.toggle("active", chip === btn);
    });

    renderProducts();
  });

  byId("productGrid")?.addEventListener("click", (e) => {
    const btn = e.target.closest("button[data-action]");
    if (!btn) return;

    if (btn.dataset.action === "details") {
      openModal(btn.dataset.id);
    }

    if (btn.dataset.action === "add") {
      addToCart(btn.dataset.id);
    }
  });

  byId("closeModal")?.addEventListener("click", closeModal);

  byId("productModal")?.addEventListener("click", (e) => {
    if (e.target.id === "productModal") {
      closeModal();
    }
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeModal();
  });
}

function cartGrandTotal() {
  return state.cart.reduce((sum, item) => sum + item.price * item.qty, 0);
}

function renderCartPage() {
  const list = byId("cartList");
  const subtotal = byId("cartSubtotal");
  const delivery = byId("cartDelivery");
  const total = byId("cartTotal");

  if (!list) return;

  if (!state.cart.length) {
    list.innerHTML = `
      <div class="empty-state card">
        <i class="fa-solid fa-basket-shopping"></i>
        <h3>Your cart is empty</h3>
        <p>Go back to the marketplace and add crop-care products.</p>
        <div class="hero-actions" style="justify-content:center;">
          <a href="../static.html" class="form-btn primary">
            <i class="fa-solid fa-store"></i>
            Continue shopping
          </a>
        </div>
      </div>
    `;

    if (subtotal) subtotal.textContent = money(0);
    if (delivery) delivery.textContent = money(0);
    if (total) total.textContent = money(0);
    return;
  }

  list.innerHTML = state.cart
    .map(
      (item) => `
        <div class="cart-row">
          <img
            class="cart-img"
            src="${escapeHtml(assetUrl(item.image))}"
            alt="${escapeHtml(item.name)}"
            onerror="this.onerror=null;this.src='${escapeHtml(item.fallback || "")}';"
          />

          <div>
            <span class="tag">
              <i class="${escapeHtml(item.icon || "fa-solid fa-seedling")}"></i>
              ${escapeHtml(item.crop || "crop")}
            </span>

            <h3>${escapeHtml(item.name)}</h3>
            <p>Unit price: ${money(item.price)}</p>
          </div>

          <div class="cart-actions">
            <strong>${money(item.price * item.qty)}</strong>

            <div class="qty-stepper">
              <button class="qty-btn" data-action="dec" data-id="${item.id}">
                <i class="fa-solid fa-minus"></i>
              </button>

              <strong>${item.qty}</strong>

              <button class="qty-btn" data-action="inc" data-id="${item.id}">
                <i class="fa-solid fa-plus"></i>
              </button>
            </div>

            <button class="icon-btn danger" data-action="remove" data-id="${item.id}">
              <i class="fa-solid fa-trash"></i>
            </button>
          </div>
        </div>
      `
    )
    .join("");

  const grand = cartGrandTotal();
  const deliveryCharge = grand > 0 ? 49 : 0;

  if (subtotal) subtotal.textContent = money(grand);
  if (delivery) delivery.textContent = money(deliveryCharge);
  if (total) total.textContent = money(grand + deliveryCharge);
}

function bindCartEvents() {
  byId("cartList")?.addEventListener("click", (e) => {
    const btn = e.target.closest("[data-action]");
    if (!btn) return;

    const id = Number(btn.dataset.id);
    const item = state.cart.find((cartItem) => cartItem.id === id);

    if (btn.dataset.action === "remove") {
      state.cart = state.cart.filter((cartItem) => cartItem.id !== id);
      showToast("Item removed from cart");
    }

    if (btn.dataset.action === "inc" && item) {
      item.qty += 1;
    }

    if (btn.dataset.action === "dec" && item) {
      item.qty -= 1;

      if (item.qty <= 0) {
        state.cart = state.cart.filter((cartItem) => cartItem.id !== id);
      }
    }

    saveCart();
    renderCartPage();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  updateCartCount();

  const page = document.body.dataset.page || "home";

  if (page === "home") {
    renderProducts();
    bindHomeEvents();
  }

  if (page === "cart") {
    renderCartPage();
    bindCartEvents();
  }
});