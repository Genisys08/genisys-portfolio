import React from "react";

type State = { hasError: boolean; msg?: string };
export default class ErrorBoundary extends React.Component<{ children: React.ReactNode }, State> {
  state: State = { hasError: false };
  static getDerivedStateFromError(err: Error) { return { hasError: true, msg: err.message }; }
  componentDidCatch(err: Error) { console.error("[Genisys] runtime error:", err); }
  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-[100dvh] grid place-items-center bg-black text-cream p-8">
          <div className="glass-strong relative max-w-md p-8 rounded-2xl text-center">
            <h1 className="font-mono text-xl gold-text mb-3">SYSTEM RECOVERY</h1>
            <p className="text-sm text-muted-foreground mb-4">A render error was caught and contained. Reloading is recommended.</p>
            <p className="text-[11px] font-mono text-gold/60 break-all">{this.state.msg}</p>
            <button
              onClick={() => location.reload()}
              className="mt-5 px-5 py-2 rounded-md bg-gold text-black font-semibold tracking-wide hover:brightness-110"
            >RELOAD</button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}
