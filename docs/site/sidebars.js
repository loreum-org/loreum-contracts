/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docs: [
    {
      type: 'doc',
      id: 'intro',
      label: 'Introduction',
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
        'contracts/board',
        'contracts/wallet',
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
  ],
};

module.exports = sidebars; 