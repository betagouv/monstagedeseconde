export const months = [
  { name: 'Janvier', days: 31 },
  { name: 'Février', days: 28 }, // 29 in leap years
  { name: 'Mars', days: 31 },
  { name: 'Avril', days: 30 },
  { name: 'Mai', days: 31 },
  { name: 'Juin', days: 30 },
  { name: 'Juillet', days: 31 },
  { name: 'Août', days: 31 },
  { name: 'Septembre', days: 30 },
  { name: 'Octobre', days: 31 },
  { name: 'Novembre', days: 30 },
  { name: 'Décembre', days: 31 }
];
export const getMonthName = (monthIndex) => {
  if (monthIndex < 0 || monthIndex >= months.length) {
    throw new Error('Invalid month index');
  }
  return months[monthIndex].name;
};

// export const monthList = () => {
//   const monthNames = rotate(months, 8); // Rotate to start from September
//   return monthNames.map(month => month.name);
// };