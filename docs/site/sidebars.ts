import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  docs: [
    {
      type: 'doc',
      id: 'intro',
      label: 'Introduction',
    },
    {
      type: 'category',
      label: 'Whitepaper',
      items: [
        'whitepaper/index',
        'whitepaper/architecture',
        'whitepaper/ai-integration',
        'whitepaper/governance',
        'whitepaper/implementation',
      ],
    },
    {
      type: 'category',
      label: 'Architecture',
      items: [
        'architecture/overview',
        'architecture/board',
        'architecture/wallet',
      ],
    },
    {
      type: 'category',
      label: 'Smart Contracts',
      items: [
        'contracts/overview',
        'contracts/chamber',
      ],
    },
    {
      type: 'category',
      label: 'User Guides',
      items: [
        'guides/getting-started',
        'guides/delegation',
        'guides/transactions',
        'guides/governance',
      ],
    },
    {
      type: 'category',
      label: 'API Reference',
      items: [
        'api/overview',
        'api/chamber',
        'api/board',
        'api/wallet',
      ],
    },
    {
      type: 'category',
      label: 'Resources',
      items: [
        'interface',
        'deployments',
      ],
    },
  ],
};

export default sidebars;
