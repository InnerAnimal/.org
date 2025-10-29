import { useState, useEffect } from 'react';

const GA_MEASUREMENT_ID = import.meta.env.VITE_GA_MEASUREMENT_ID;

/**
 * Hook for Google Analytics tracking
 */
export function useAnalytics() {
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    if (GA_MEASUREMENT_ID && typeof window !== 'undefined' && window.gtag) {
      setIsReady(true);
    } else if (GA_MEASUREMENT_ID) {
      // Initialize gtag if not already loaded
      const script = document.createElement('script');
      script.src = `https://www.googletagmanager.com/gtag/js?id=${GA_MEASUREMENT_ID}`;
      script.async = true;
      document.head.appendChild(script);

      window.dataLayer = window.dataLayer || [];
      function gtag(...args) {
        window.dataLayer.push(args);
      }
      window.gtag = gtag;

      gtag('js', new Date());
      gtag('config', GA_MEASUREMENT_ID);

      setIsReady(true);
    }
  }, []);

  const trackEvent = (eventName, eventParams = {}) => {
    if (isReady && window.gtag) {
      window.gtag('event', eventName, eventParams);
    }
  };

  const trackPageView = (path) => {
    if (isReady && window.gtag) {
      window.gtag('config', GA_MEASUREMENT_ID, {
        page_path: path,
      });
    }
  };

  return {
    isReady,
    trackEvent,
    trackPageView,
  };
}

