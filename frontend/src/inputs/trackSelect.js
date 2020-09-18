import * as React from "react";
import PropTypes from 'prop-types';
import { SelectInput } from 'react-admin';

export const TrackSelectInput = ({ source, record = {}}) => {
  return <SelectInput source={source} record={record} choices={[
    { id: 'DS', name: 'Data Science' },
    { id: 'AI', name: 'Artificial Intelligence' },
    { id: 'WEBDEV', name: 'Web Development' },
    { id: 'UX', name: 'User Experience Design' },
  ]} />
}

TrackSelectInput.propTypes = {
  label: PropTypes.string,
  record: PropTypes.object,
  source: PropTypes.string.isRequired,
};

TrackSelectInput.defaultProps = {
  addLabel: true
}
