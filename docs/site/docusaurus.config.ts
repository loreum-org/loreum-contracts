import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Docs',
  tagline: 'AI-Powered Decentralized Governance',
<<<<<<< HEAD
<<<<<<< HEAD
  favicon: 'https://cdn.loreum.org/logos/black.png',
=======
  favicon: 'https://cdn.loreum.org/logos/black.svg',
>>>>>>> 61b19f9 (Update docs site)
=======
  favicon: 'https://cdn.loreum.org/logos/black.png',
>>>>>>> 68ba331 (update favicon)

  // Set the production url of your site here
  url: 'https://docs.loreum.org',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'loreum-org', // Usually your GitHub org/user name.
  projectName: 'chamber', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  markdown: {
    mermaid: true,
  },
  
  themes: ['@docusaurus/theme-mermaid'],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
          editUrl: 'https://github.com/loreum-org/chamber/tree/main/docs/site/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'Loreum Documentation',
      logo: {
        alt: 'Loreum Logo',
        src: 'https://cdn.loreum.org/logos/black.svg',
        srcDark: 'https://cdn.loreum.org/logos/white.svg',
      },
      items: [
        // {
        //   type: 'docSidebar',
        //   sidebarId: 'docs',
        //   position: 'left',
        //   label: 'Documentation',
        // },
        {
          href: 'https://github.com/loreum-org',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {
              label: 'Introduction',
              to: '/intro',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'Discord',
              href: 'https://discord.gg/Pb3d5hRV',
            },
            {
              label: 'Twitter',
              href: 'https://twitter.com/loreumdao',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Loreum DAO LLC`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
