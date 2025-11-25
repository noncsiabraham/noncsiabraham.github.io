(function(){
  function closeAll() {
    document.querySelectorAll('.nav-toggle').forEach(function(t){ t.checked = false; });
  }

  document.addEventListener('click', function(e){
    document.querySelectorAll('.top-right').forEach(function(tr){
      var toggle = tr.querySelector('.nav-toggle');
      if (!toggle) return;
      if (toggle.checked && !tr.contains(e.target)) toggle.checked = false;
    });
  }, true);

  document.addEventListener('keydown', function(e){
    if (e.key === 'Escape') closeAll();
  });

  document.querySelectorAll('.nav-links a').forEach(function(a){
    a.addEventListener('click', function(){
      var tr = a.closest('.top-right');
      if (!tr) return;
      var toggle = tr.querySelector('.nav-toggle');
      if (toggle) toggle.checked = false;
    });
  });
})();

// Cursor follower for hover preview images
(function(){
  var follower = document.getElementById('cursor-follower');
  if (!follower) return;

  var currentImage = null;

  document.querySelectorAll('.hover-preview').forEach(function(elem){
    elem.addEventListener('mouseenter', function(e){
      var imgSrc = elem.getAttribute('data-hover-image');
      if (!imgSrc) return;

      currentImage = imgSrc;
      
      // Load image to get natural dimensions
      var img = new Image();
      img.onload = function(){
        var ratio = img.naturalWidth / img.naturalHeight;
        var width, height;
        
        if (ratio > 1) {
          // Landscape
          width = Math.min(500, img.naturalWidth);
          height = width / ratio;
        } else {
          // Portrait or square
          height = Math.min(500, img.naturalHeight);
          width = height * ratio;
        }
        
        follower.style.width = width + 'px';
        follower.style.height = height + 'px';
        follower.style.backgroundImage = 'url(' + imgSrc + ')';
        follower.classList.add('active');
      };
      img.src = imgSrc;
    });

    elem.addEventListener('mousemove', function(e){
      if (currentImage) {
        var offsetX = 20;
        var offsetY = 20;
        var followerWidth = follower.offsetWidth || 500;
        var followerHeight = follower.offsetHeight || 500;
        
        // Check if image would go off the right edge
        if (e.clientX + offsetX + followerWidth > window.innerWidth) {
          offsetX = -followerWidth - 20;
        }
        
        // Check if image would go off the bottom edge
        if (e.clientY + offsetY + followerHeight > window.innerHeight) {
          offsetY = -followerHeight - 20;
        }
        
        follower.style.left = e.clientX + offsetX + 'px';
        follower.style.top = e.clientY + offsetY + 'px';
      }
    });

    elem.addEventListener('mouseleave', function(){
      currentImage = null;
      follower.classList.remove('active');
      follower.style.backgroundImage = '';
    });
  });
})();

// Image lightbox - click to view full size
(function(){
  // Create lightbox elements
  var lightbox = document.createElement('div');
  lightbox.className = 'lightbox';
  lightbox.innerHTML = '<img class="lightbox-image" src="" alt=""><span class="lightbox-close">&times;</span><span class="lightbox-prev">&#8249;</span><span class="lightbox-next">&#8250;</span>';
  document.body.appendChild(lightbox);

  var lightboxImg = lightbox.querySelector('.lightbox-image');
  var closeBtn = lightbox.querySelector('.lightbox-close');
  var prevBtn = lightbox.querySelector('.lightbox-prev');
  var nextBtn = lightbox.querySelector('.lightbox-next');

  var images = [];
  var currentIndex = 0;

  // Collect all gallery images on the page
  document.querySelectorAll('.image-gallery img, .subaquatica-gallery img').forEach(function(img, index){
    images.push(img.src);
    img.style.cursor = 'pointer';
    img.addEventListener('click', function(e){
      e.preventDefault();
      currentIndex = index;
      showImage(currentIndex);
      lightbox.classList.add('active');
    });
  });

  function showImage(index){
    if (index < 0) index = images.length - 1;
    if (index >= images.length) index = 0;
    currentIndex = index;
    lightboxImg.src = images[currentIndex];
  }

  // Navigation
  prevBtn.addEventListener('click', function(e){
    e.stopPropagation();
    showImage(currentIndex - 1);
  });

  nextBtn.addEventListener('click', function(e){
    e.stopPropagation();
    showImage(currentIndex + 1);
  });

  // Close lightbox
  function closeLightbox(){
    lightbox.classList.remove('active');
  }

  closeBtn.addEventListener('click', closeLightbox);
  lightbox.addEventListener('click', function(e){
    if (e.target === lightbox) closeLightbox();
  });
  
  // Keyboard navigation
  document.addEventListener('keydown', function(e){
    if (!lightbox.classList.contains('active')) return;
    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowLeft') showImage(currentIndex - 1);
    if (e.key === 'ArrowRight') showImage(currentIndex + 1);
  });
})();
