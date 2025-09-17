document.addEventListener('DOMContentLoaded', function() {
  const form = document.getElementById('contactForm');
  const submitBtn = document.getElementById('submitBtn');
  const submitText = document.getElementById('submitText');
  const statusMessage = document.getElementById('statusMessage');

  form.addEventListener('submit', async function(e) {
    e.preventDefault();

    // Get form data
    const formData = new FormData(form);
    const data = {
      name: formData.get('name'),
      email: formData.get('email'),
      subject: formData.get('subject'),
      message: formData.get('message')
    };

    // Update button state
    submitBtn.disabled = true;
    submitText.textContent = 'Sending...';
    submitBtn.classList.add('loading');

    // Hide any previous status message
    statusMessage.classList.add('hidden');

    try {
      const response = await fetch('https://form.guillaume.genois.ca/api/contact', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
      });

      if (response.ok) {
        // Success
        statusMessage.className = 'alert alert-success';
        statusMessage.innerHTML = `
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>Message sent successfully! I'll get back to you soon.</span>
        `;

        // Reset form
        form.reset();
      } else {
        throw new Error('Error sending message');
      }
    } catch (error) {
      // Error
      statusMessage.className = 'alert alert-error';
      statusMessage.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span>Error sending message. Please try again or email me directly.</span>
      `;
    } finally {
      // Reset button state
      submitBtn.disabled = false;
      submitText.textContent = 'Send Message';
      submitBtn.classList.remove('loading');

      // Show status message
      statusMessage.classList.remove('hidden');
    }
  });
});