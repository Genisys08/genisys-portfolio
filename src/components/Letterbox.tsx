import { motion } from "framer-motion";
import { useEffect, useState } from "react";

let pulse: () => void = () => {};
export function pulseLetterbox() { pulse(); }

export default function Letterbox() {
  const [active, setActive] = useState(false);
  useEffect(() => {
    pulse = () => { setActive(true); setTimeout(() => setActive(false), 700); };
    return () => { pulse = () => {}; };
  }, []);
  return (
    <>
      <motion.div className="letterbox-bar top-0 h-[10vh]"
        initial={{ y: "-100%" }}
        animate={{ y: active ? "0%" : "-100%" }}
        transition={{ duration: 0.45, ease: [0.7, 0, 0.3, 1] }} />
      <motion.div className="letterbox-bar bottom-0 h-[10vh]"
        initial={{ y: "100%" }}
        animate={{ y: active ? "0%" : "100%" }}
        transition={{ duration: 0.45, ease: [0.7, 0, 0.3, 1] }} />
    </>
  );
}
