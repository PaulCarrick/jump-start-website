// app/javascript/components/NavMenu.jsx

import React from 'react';
import PropTypes from 'prop-types';

const NavMenu = ({menuItems = []}) => {
  return (
    <div className="container">
      <button
        className="navbar-toggler"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#navbarNavDropdown"
        aria-controls="navbarNavDropdown"
        aria-expanded="false"
        aria-label="Toggle navigation"
      >
      <span className="navbar-toggler-icon"/>
      </button>
      <div className="collapse navbar-collapse" id="navbarNavDropdown">
        <ul className="ms-auto navbar-nav">
          {menuItems.map((item, index) => (
            <li key={index} className="nav-item">
              { (item.sub_items.length > 0) ? (
                // Render dropdown for items with a submenu
                <div className="dropdown">
                  <a
                    className="nav-link dropdown-toggle px-lg-3 py-lg-4 text-uppercase"
                    href="#"
                    id={`navbarDropdown-${index}`}
                    role="button"
                    data-bs-toggle="dropdown"
                    aria-expanded="false"
                  >
                    {item.label}
                  </a>
                  <ul className="dropdown-menu" aria-labelledby={`navbarDropdown-${index}`}>
                    {item.sub_items.map((subItem, subIndex) => (
                      <li key={subIndex}>
                        <a className="dropdown-item" href={subItem.link}>
                          {subItem.label}
                        </a>
                      </li>
                    ))}
                  </ul>
                </div>
              ) : (
                // Render regular item with a conditional for SVG icon button
                (item.options === "image-file") ? (
                  <img src={item.icon} alt={item.icon} style={{ paddingTop: '20px' }} />
                ) : (
                  <a className="nav-link px-lg-3 py-lg-4 text-uppercase" href={item.link}>
                    {item.label}
                  </a>
                )
              )}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

NavMenu.propTypes = {
  menuItems: PropTypes.arrayOf(
    PropTypes.shape({
                      label: PropTypes.string.isRequired,
                      link: PropTypes.string,
                      sub_items: PropTypes.arrayOf(
                        PropTypes.shape({
                                          label: PropTypes.string.isRequired,
                                          link: PropTypes.string
                                        })
                      ).isRequired,
                      options: PropTypes.string,
                      icon: PropTypes.string,
                    })
  ).isRequired
};

export default NavMenu;
