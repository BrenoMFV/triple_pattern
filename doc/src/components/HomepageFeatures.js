import React from 'react';
import clsx from 'clsx';
import styles from './HomepageFeatures.module.css';

const FeatureList = [
  {
    title: 'Easy to Use',
    Svg: require('../../static/img/undraw_docusaurus_mountain.svg').default,
    description: (
      <>
Triple was designed from the ground up to be easy while maintaining scalability and is perfect for large projects.      </>
    ),
  },
  {
    title: 'Any Reactivity',
    Svg: require('../../static/img/undraw_docusaurus_tree.svg').default,
    description: (
      <>
        SSP is a pattern that can be extended to be used with any reactivity making it more solid.
      </>
    ),
  },
  {
    title: 'Open source',
    Svg: require('../../static/img/undraw_docusaurus_react.svg').default,
    description: (
      <>
        Created and maintained by the largest Flutter community in Brazil and free for everyone!
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} alt={title} />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
