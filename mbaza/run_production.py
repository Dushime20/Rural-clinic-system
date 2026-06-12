"""
Production server for Mbaza Translation Service using Waitress
Handles concurrent requests better than Flask development server
"""
from waitress import serve
from app_optimized import app

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 Starting Mbaza Translation Service (PRODUCTION MODE)")
    print("=" * 60)
    print("Server: Waitress (production-grade)")
    print("Host: 0.0.0.0:9000")
    print("Threading: Enabled (4 worker threads)")
    print("=" * 60)
    
    # Serve with Waitress - production-grade WSGI server
    serve(
        app,
        host='0.0.0.0',
        port=9000,
        threads=4,  # Handle up to 4 concurrent requests
        channel_timeout=120,  # 2 minute timeout per request
        connection_limit=100,  # Max connections
        cleanup_interval=30,  # Clean up idle connections every 30s
        asyncore_use_poll=True  # Better performance on Windows
    )
