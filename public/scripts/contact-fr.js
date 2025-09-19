console.log('Script tag executing!');

function initializeContactForm() {
  console.log('French contact script loaded!');
  const form = document.getElementById('contactForm');
  const submitBtn = document.getElementById('submitBtn');
  const submitText = document.getElementById('submitText');
  const statusMessage = document.getElementById('statusMessage');

  if (!form) {
    console.error('Contact form not found!');
    return;
  }

  // Remove any existing event listeners to prevent duplicates
  const newForm = form.cloneNode(true);
  form.parentNode.replaceChild(newForm, form);

  // Get fresh references after cloning
  const currentForm = document.getElementById('contactForm');
  const currentSubmitBtn = document.getElementById('submitBtn');
  const currentSubmitText = document.getElementById('submitText');
  const currentStatusMessage = document.getElementById('statusMessage');

  currentForm.addEventListener('submit', async function(e) {
    e.preventDefault();
    console.log('Form submitted!');

    // Get form data
    const formData = new FormData(currentForm);
    const data = {
      name: formData.get('name'),
      email: formData.get('email'),
      subject: formData.get('subject'),
      message: formData.get('message')
    };

    console.log('Sending data:', data);

    // Update button state
    currentSubmitBtn.disabled = true;
    currentSubmitText.textContent = 'Envoi en cours...';
    currentSubmitBtn.classList.add('loading');

    // Hide any previous status message
    currentStatusMessage.classList.add('hidden');

    try {
      console.log('Making fetch request...');
      const response = await fetch('https://form.guillaume.genois.ca/api/contact', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
      });

      console.log('Response status:', response.status);
      console.log('Response ok:', response.ok);

      if (response.ok) {
        // Success
        currentStatusMessage.className = 'alert alert-success';
        currentStatusMessage.innerHTML = `
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>Message envoyé avec succès! Je vous répondrai bientôt.</span>
        `;

        // Reset form
        currentForm.reset();
      } else {
        throw new Error('Erreur lors de l\'envoi');
      }
    } catch (error) {
      // Error
      console.error('Fetch error:', error);
      currentStatusMessage.className = 'alert alert-error';
      currentStatusMessage.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span>Erreur lors de l'envoi du message. Veuillez réessayer ou m'envoyer un email directement.</span>
      `;
    } finally {
      // Reset button state
      currentSubmitBtn.disabled = false;
      currentSubmitText.textContent = 'Envoyer le Message';
      currentSubmitBtn.classList.remove('loading');

      // Show status message
      currentStatusMessage.classList.remove('hidden');
    }
  });
}

// Initialize on both DOMContentLoaded and Astro page transitions
document.addEventListener('DOMContentLoaded', initializeContactForm);
document.addEventListener('astro:page-load', initializeContactForm);