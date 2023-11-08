import flatpickr from "../vendor/flatpickr"
import { AsYouType } from "../vendor/libphonenumber-js.min"

let Hooks = {}

Hooks.Calendar = {
    mounted() {
        this.pickr = flatpickr(this.el, {
            inline: true,
            mode: "range",
            showMonths: 2,
            onChange: (selectedDates) => {
                if (selectedDates.length != 2) return;
                this.pushEvent("dates-picked", selectedDates)
            }
        })
        this.handleEvent("add-unavailable-dates", (dates) => {
            this.pickr.set("disable", [dates, ...this.pickr.config.disable])
        })
        this.pushEvent("unavailable-dates", {}, (reply, ref) => {
            this.pickr.set("disable", reply.dates)
        })
    },
    destroyed() {
        this.pickr.destroy()
    }
}

Hooks.PhoneNumber = {
    mounted() {
        this.el.addEventListener("input", e => {
            this.el.value = new AsYouType("US").input(this.el.value);
        });
    },
}

Hooks.Clipboard = {
    mounted() {
        const initialInnerHTML = this.el.innerHTML;
        const { content } = this.el.dataset;

        this.el.addEventListener("click", () => {
            navigator.clipboard.writeText(content);

            this.el.innerHTML = "Copied!";

            setTimeout(() => {
                this.el.innerHTML = initialInnerHTML;
            }, 2000);
        });
    },
}

export default Hooks