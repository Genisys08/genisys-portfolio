import {
  createContext, useCallback, useContext,
  useEffect, useRef, useState, type ReactNode,
} from "react";
import { motion, AnimatePresence } from "framer-motion";
import { CheckCircle, Info, AlertCircle } from "lucide-react";

interface ToastItem { id: number; message: string; type: "success" | "info" | "error"; }
type PushFn = (message: string, type?: ToastItem["type"]) => void;

const Ctx = createContext<PushFn>(() => {});

let _idCounter = 0;

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([]);
  const timers = useRef<Map<number, ReturnType<typeof setTimeout>>>(new Map());

  const dismiss = useCallback((id: number) => {
    setToasts(p => p.filter(t => t.id !== id));
    const t = timers.current.get(id);
    if (t) { clearTimeout(t); timers.current.delete(id); }
  }, []);

  const push = useCallback<PushFn>((message, type = "success") => {
    const id = ++_idCounter;
    setToasts(p => [...p.slice(-2), { id, message, type }]); // max 3
    const t = setTimeout(() => dismiss(id), 2800);
    timers.current.set(id, t);
  }, [dismiss]);

  useEffect(() => () => { timers.current.forEach(clearTimeout); }, []);

  const icons: Record<ToastItem["type"], React.ReactNode> = {
    success: <CheckCircle className="w-4 h-4 text-gold flex-none" />,
    info:    <Info        className="w-4 h-4 text-gold flex-none" />,
    error:   <AlertCircle className="w-4 h-4 text-red-400 flex-none" />,
  };

  return (
    <Ctx.Provider value={push}>
      {children}

      {/* Toast stack — bottom-centre, above everything except cursor */}
      <div
        aria-live="polite"
        className="fixed left-1/2 -translate-x-1/2 z-[9700] flex flex-col items-center gap-2 pointer-events-none"
        style={{ bottom: "max(env(safe-area-inset-bottom, 0px), 80px)" }}
      >
        <AnimatePresence mode="popLayout">
          {toasts.map(t => (
            <motion.div
              key={t.id}
              layout
              initial={{ opacity: 0, y: 16, scale: 0.92 }}
              animate={{ opacity: 1, y: 0,  scale: 1 }}
              exit={{   opacity: 0, y: -8,  scale: 0.95 }}
              transition={{ duration: 0.3, ease: [0.7, 0, 0.3, 1] }}
              onClick={() => dismiss(t.id)}
              className="flex items-center gap-2.5 px-5 py-3 rounded-full glass-strong specular pointer-events-auto cursor-pointer whitespace-nowrap"
              style={{ border: "1px solid hsl(44 70% 55% / 0.35)" }}
            >
              {icons[t.type]}
              <span className="font-mono text-[10px] tracking-[0.25em] text-cream/85">
                {t.message}
              </span>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>
    </Ctx.Provider>
  );
}

/** Use this hook anywhere inside <ToastProvider> to push a toast. */
export function useToast(): PushFn {
  return useContext(Ctx);
}
