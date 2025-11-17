import { Link } from 'react-router-dom';

const NotFoundPage = () => {
  return (
    <div className="flex flex-col items-center justify-center h-screen">
      <h1 className="text-6xl font-bold">404</h1>
      <p className="mt-4 text-xl text-muted-foreground">Page Not Found</p>
      <Link to="/" className="mt-8 px-4 py-2 text-white bg-primary rounded-md hover:bg-primary/90">
        Go Home
      </Link>
    </div>
  );
};

export default NotFoundPage;
