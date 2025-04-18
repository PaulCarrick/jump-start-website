// app/javascript/components/RenderPage.tsx

import React             from "react";
import RenderSection     from "./RenderSection";
import { Page, Section } from "../types/dataTypes";

interface PageProps {
  page: Page;
  editing?: boolean | undefined;
  noBorder?: boolean | undefined;
  noHidden?: boolean | undefined;
}

const RenderPage: React.FC<PageProps> = ({
                                           page,
                                           editing = false,
                                           noBorder = true,
                                           noHidden = false
                                         }) => {
  return (
      <div className="RenderPageDiv">
        {page.sections && page.sections.length > 0 ? (
            page.sections.map((section: Section, index: number) => (
                <div key={index} className="section">
                  <RenderSection
                      section={section as any}
                      editing={editing}
                      noBorder={noBorder}
                      noHidden={noHidden}
                  />
                </div>
            ))
        ) : (
             <p>No sections available</p>
         )
        }
      </div>
  );
};

export default RenderPage;
