import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Header } from './Header';

export function Layout() {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <div className="min-h-screen bg-gray-50">
      <Sidebar collapsed={collapsed} onToggle={() => setCollapsed(!collapsed)} />
      <Header sidebarCollapsed={collapsed} />
      <main
        className="transition-all duration-300 pt-16"
        style={{ marginLeft: collapsed ? '4rem' : '16rem' }}
      >
        <div className="p-6">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
