// Configuration centralisée de l'API
export const API_BASE_URL = 
  process.env.NEXT_PUBLIC_API_BASE_URL || 
  'http://localhost:8080/api';

export const API_URL = API_BASE_URL.replace('/api', '');
