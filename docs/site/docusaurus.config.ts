import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Loreum Documentation',
  tagline: 'AI-Powered Decentralized Governance',
  favicon: 'https://cdn.loreum.org/logos/black.svg',

  // Update the baseUrl for GitHub Pages
  baseUrl: '/chamber/',
  url: 'https://loreum-org.github.io', // Your GitHub organization or username

  // GitHub pages deployment config
  organizationName: 'loreum-org',
  projectName: 'chamber',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,

  // ... rest of config remains the same ...
};

export default config; 