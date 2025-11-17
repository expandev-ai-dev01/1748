import { ErrorBoundary } from '@/core/components/ErrorBoundary';
import { Outlet, Link, useLocation } from 'react-router-dom';

export const AppLayout = () => {
  const location = useLocation();

  return (
    <ErrorBoundary>
      <div className="flex h-screen flex-col">
        <header className="border-b p-4">
          <div className="flex items-center justify-between max-w-6xl mx-auto">
            <h1 className="text-xl font-semibold">TO DO List App</h1>
            <nav className="flex gap-4">
              <Link
                to="/"
                className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                  location.pathname === '/'
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:text-foreground hover:bg-muted'
                }`}
              >
                Home
              </Link>
              <Link
                to="/ai-automation"
                className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                  location.pathname === '/ai-automation'
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:text-foreground hover:bg-muted'
                }`}
              >
                AI Automation
              </Link>
            </nav>
          </div>
        </header>
        <main className="flex-1 overflow-y-auto p-8">
          <Outlet />
        </main>
      </div>
    </ErrorBoundary>
  );
};
