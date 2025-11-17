import { ErrorBoundary } from '@/core/components/ErrorBoundary';
import { Outlet } from 'react-router-dom';

export const AppLayout = () => {
  return (
    <ErrorBoundary>
      <div className="flex h-screen flex-col">
        {/* Header can go here */}
        <header className="border-b p-4">
          <h1 className="text-xl font-semibold">TO DO List App</h1>
        </header>
        <main className="flex-1 overflow-y-auto p-8">
          <Outlet />
        </main>
        {/* Footer can go here */}
      </div>
    </ErrorBoundary>
  );
};
