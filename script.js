document.addEventListener("DOMContentLoaded", function () {
          const navbarLinks = document.querySelectorAll(".navbar__link");
      
          // Add click event listeners to navbar links
          navbarLinks.forEach(link => {
              link.addEventListener("click", function (event) {
                  // Remove active class from all links
                  navbarLinks.forEach(link => link.classList.remove("active"));
      
                  // Add active class to the clicked link
                  link.classList.add("active");
              });
          });
      });
      