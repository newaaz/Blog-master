import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link"];

  downloadReport(event) {
    event.preventDefault();

    const form = this.element.closest('form'); // Находим ближайшую форму

    const formData = new FormData(form);
    let params = '';
    formData.forEach((value, key) => {
      const parsedValue = key === 'start_date' || key === 'end_date' ? value : encodeURIComponent(value);
      params += `${key}=${parsedValue}&`;
    });
    params = params.slice(0, -1);

//    const reportUrl = `/posts/report?${params}`;
    const reportUrl = `/posts?${params}&format=xlsx`;
    window.location.href = reportUrl;
  }
}
