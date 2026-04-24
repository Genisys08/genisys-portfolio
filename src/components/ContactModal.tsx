import { useState, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Send, CheckCircle, AlertCircle } from "lucide-react";

interface Props { open: boolean; onClose: () => void; }
type Status = "idle" | "sending" | "sent" | "error";

export default function ContactModal({ open, onClose }: Props) {
  const [status, setStatus] = useState<Status>("idle");
  const formRef = useRef<HTMLFormElement>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formRef.current || status === "sending") return;
    setStatus("sending");
    try {
      const data = new FormData(formRef.current);
      const res = await fetch("https://api.web3forms.com/submit", { method: "POST", body: data });
      const json = await res.json();
      if (json.success) {
        setStatus("sent");
        setTimeout(() => { setStatus("idle"); onClose(); formRef.current?.reset(); }, 3000);
      } else setStatus("error");
    } catch { setStatus("error"); }
  };

  const handleClose = () => {
    if (status === "sending") return;
    setStatus("idle");
    onClose();
  };

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          transition={{ duration: 0.3 }}
          className="fixed inset-0 z-[200] grid place-items-center p-4 sm:p-8"
          style={{
            backdropFilter: "blur(24px)",
            background: "radial-gradient(80% 60% at 50% 50%, rgba(212,175,55,0.07), rgba(0,0,0,0.94))",
          }}
          onClick={handleClose}
        >
          <motion.div
            initial={{ scale: 0.94, y: 32, opacity: 0 }}
            animate={{ scale: 1, y: 0, opacity: 1 }}
            exit={{ scale: 0.96, y: 16, opacity: 0 }}
            transition={{ duration: 0.42, ease: [0.7, 0, 0.3, 1] }}
            /* V2.5: max-h-[85vh] + overflow-y-auto so Send/Cancel always reachable */
            className="relative w-full max-w-lg max-h-[85vh] overflow-y-auto glass-strong specular grain rounded-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="relative px-7 pt-7 pb-5 border-b border-white/[0.06]">
              <div className="font-mono text-[10px] tracking-[0.45em] text-gold/80">
                SECURE CHANNEL · WEB3FORMS
              </div>
              <h2 className="mt-2 font-display font-black text-3xl sm:text-4xl gold-text chromatic">
                START A PROJECT
              </h2>
              <p className="mt-1.5 text-cream/80 text-sm">
                Tell us what you're building. We'll make it iconic.
              </p>
              <button
                onClick={handleClose}
                aria-label="Close contact modal"
                disabled={status === "sending"}
                style={{ zIndex: 9999 }}
                className="absolute top-6 right-6 grid place-items-center w-9 h-9 rounded-full glass-strong gold-border-glow disabled:opacity-40"
              >
                <X className="w-4 h-4 text-gold" />
              </button>
            </div>

            <div className="px-7 py-6">
              {status === "sent" ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}
                  className="flex flex-col items-center gap-4 py-8 text-center"
                >
                  <CheckCircle className="w-14 h-14 text-gold" strokeWidth={1.5} />
                  <div className="font-display font-black text-2xl gold-text">Transmission Received</div>
                  <p className="text-cream/80 text-sm max-w-xs">
                    Your brief is in. We'll respond within 24 hours with a direction.
                  </p>
                  <div className="font-mono text-[10px] tracking-[0.3em] text-gold/60">CLOSING IN 3s...</div>
                </motion.div>
              ) : (
                <form ref={formRef} onSubmit={handleSubmit} className="space-y-4">
                  <input type="hidden" name="access_key" value="a71a80eb-c0dc-4ad0-8a31-f89ae7687ee1" />
                  <input type="hidden" name="subject" value="New Project Inquiry — Genisys Studio" />
                  <input type="hidden" name="from_name" value="Genisys Contact Form" />
                  <input type="checkbox" name="botcheck" style={{ display: "none" }} defaultChecked={false} />

                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block font-mono text-[10px] tracking-[0.3em] text-gold/80 mb-1.5">YOUR NAME</label>
                      <input type="text" name="name" required placeholder="e.g. Jordan Mercer"
                        className="w-full bg-white/[0.04] border border-white/10 rounded-xl px-4 py-3 text-cream text-sm placeholder:text-cream/30 focus:outline-none focus:border-gold/50 transition-colors" />
                    </div>
                    <div>
                      <label className="block font-mono text-[10px] tracking-[0.3em] text-gold/80 mb-1.5">EMAIL ADDRESS</label>
                      <input type="email" name="email" required placeholder="you@brand.com"
                        className="w-full bg-white/[0.04] border border-white/10 rounded-xl px-4 py-3 text-cream text-sm placeholder:text-cream/30 focus:outline-none focus:border-gold/50 transition-colors" />
                    </div>
                  </div>

                  <div>
                    <label className="block font-mono text-[10px] tracking-[0.3em] text-gold/80 mb-1.5">PROJECT TYPE</label>
                    <div className="relative">
                      <select name="project_type"
                        className="w-full bg-white/[0.04] border border-white/10 rounded-xl px-4 py-3 text-cream text-sm focus:outline-none focus:border-gold/50 transition-colors appearance-none cursor-pointer">
                        <option value="Brand Identity System" className="bg-black">Brand Identity System</option>
                        <option value="Logo & Mark Design" className="bg-black">Logo &amp; Mark Design</option>
                        <option value="Cinematic Flyer / Campaign" className="bg-black">Cinematic Flyer / Campaign</option>
                        <option value="Packaging & Print" className="bg-black">Packaging &amp; Print</option>
                        <option value="Full Visual Direction" className="bg-black">Full Visual Direction</option>
                        <option value="Other" className="bg-black">Other — Let's Talk</option>
                      </select>
                      <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-gold/60 text-xs">▾</div>
                    </div>
                  </div>

                  <div>
                    <label className="block font-mono text-[10px] tracking-[0.3em] text-gold/80 mb-1.5">YOUR BRIEF</label>
                    <textarea name="message" required rows={4}
                      placeholder="Tell us about your brand, vision, timeline, and budget..."
                      className="w-full bg-white/[0.04] border border-white/10 rounded-xl px-4 py-3 text-cream text-sm placeholder:text-cream/30 focus:outline-none focus:border-gold/50 transition-colors resize-none" />
                  </div>

                  {status === "error" && (
                    <div className="flex items-center gap-2 text-red-400">
                      <AlertCircle className="w-4 h-4 shrink-0" />
                      <span className="font-mono text-[10px] tracking-[0.2em]">
                        TRANSMISSION FAILED — CHECK CONNECTION AND RETRY.
                      </span>
                    </div>
                  )}

                  <div className="flex gap-3 pt-2">
                    <button type="button" onClick={handleClose}
                      className="flex-1 px-5 py-3.5 rounded-full border border-white/15 text-cream/80 font-mono text-xs tracking-[0.3em] hover:border-gold/50 hover:text-gold transition-colors">
                      CANCEL
                    </button>
                    <button type="submit" disabled={status === "sending"}
                      className="flex-[2] flex items-center justify-center gap-3 px-6 py-3.5 rounded-full bg-gold text-black font-semibold text-sm tracking-[0.15em] hover:bg-cream transition-colors disabled:opacity-50">
                      {status === "sending" ? "TRANSMITTING…" : (<>SEND <Send className="w-4 h-4" /></>)}
                    </button>
                  </div>
                </form>
              )}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
